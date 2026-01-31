import argparse
import cv2
import numpy as np
from shapely import Polygon
from shapely import constrained_delaunay_triangles


def create_cardboard_mesh(image_path, output_obj='sprite_mesh.obj', 
                          simplification=0.01, extrusion=0.1):
    """
    Crée un mesh 3D cardboard à partir d'un sprite 2D
    
    Args:
        image_path: Chemin vers l'image sprite
        output_obj: Fichier OBJ de sortie
        simplification: Facteur de simplification du contour (0.001-0.1)
        extrusion: Épaisseur du cardboard
    """
    # 1. Charger l'image avec canal alpha
    img = cv2.imread(image_path, cv2.IMREAD_UNCHANGED)
    
    # 2. Extraire le canal alpha (masque de transparence)
    if img.shape[2] == 4:
        alpha = img[:, :, 3]
    else:
        # Si pas de canal alpha, créer un masque basé sur le blanc
        gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
        _, alpha = cv2.threshold(gray, 250, 255, cv2.THRESH_BINARY_INV)
    
    # 3. Trouver les contours
    contours, _ = cv2.findContours(alpha, cv2.RETR_EXTERNAL, 
                                    cv2.CHAIN_APPROX_SIMPLE)
    
    # 4. Prendre le plus grand contour
    if not contours:
        raise ValueError("Aucun contour trouvé")
    
    main_contour = max(contours, key=cv2.contourArea)
    
    # 5. Simplifier le contour (pour le rendre plus angulaire)
    epsilon = simplification * cv2.arcLength(main_contour, True)
    simplified = cv2.approxPolyDP(main_contour, epsilon, True)
    
    # 6. Normaliser les coordonnées
    h, w = img.shape[:2]
    vertices = simplified.reshape(-1, 2).astype(float)
    vertices[:, 0] = (vertices[:, 0] / w) - 0.5  # Centrer en X
    vertices[:, 1] = 0.5 - (vertices[:, 1] / h)  # Centrer en Y et inverser

    polygon = Polygon(vertices)
    tri = constrained_delaunay_triangles(polygon)

    triangles = []
    t: Polygon
    for t in tri.geoms:
        points = list(t.exterior.coords)
        for i in range(3):
            px, py = points[i]
            a = np.argwhere(np.all(vertices == np.array([px, py]), axis=1))
            triangles.append(a[0, 0])
    
    # 7. Créer le mesh 3D (cardboard = 2 faces)
    vertices_3d = []
    faces = []
    uvs = []
    
    # Face avant (z = 0)
    for i, v in enumerate(vertices):
        vertices_3d.append([v[0], v[1], 0])
        uvs.append([(v[0] + 0.5), (v[1] + 0.5)])
    
    # Face arrière (z = -extrusion)
    for i, v in enumerate(vertices):
        vertices_3d.append([v[0], v[1], -extrusion])
        uvs.append([(v[0] + 0.5), (v[1] + 0.5)])
    
    n = len(vertices)

    # Triangulation de la face avant
    for i in range(0, len(triangles), 3):
        faces.append([
            triangles[i] + 1,
            triangles[i + 1] + 1,
            triangles[i + 2] + 1 
        ])
    
    # Triangulation de la face arrière (ordre inversé)
    for i in range(0, len(triangles), 3):
        faces.append([
            triangles[i] + n + 1,
            triangles[i + 1] + n + 1,
            triangles[i + 2] + n + 1 
        ])
    
    # triangulation des faces du "cote"
    for i in range(n):
        next_i = (i + 1) % n
        
        front_curr = i + 1
        front_next = next_i + 1
        back_curr = n + i + 1
        back_next = n + next_i + 1
        
        # Premier triangle de la face latérale
        faces.append([front_curr, front_next, back_curr])
        
        # Deuxième triangle de la face latérale
        faces.append([front_next, back_next, back_curr])

    # 8. Exporter en OBJ
    with open(output_obj, 'w') as f:
        f.write("# Sprite Cardboard Mesh\n")
        f.write(f"mtllib {output_obj.replace('.obj', '.mtl')}\n\n")
        
        # Vertices
        for v in vertices_3d:
            f.write(f"v {v[0]:.6f} {v[1]:.6f} {v[2]:.6f}\n")
        
        f.write("\n")
        
        # UVs
        for uv in uvs:
            f.write(f"vt {uv[0]:.6f} {uv[1]:.6f}\n")
        
        f.write("\n")
        f.write("usemtl sprite_material\n")
        
        # Faces
        for face in faces:
            f.write(f"f {face[0]}/{face[0]} {face[1]}/{face[1]} {face[2]}/{face[2]}\n")
    
    print(f"Mesh créé : {output_obj}")
    print(f"Vertices : {len(vertices_3d)}, Faces : {len(faces)}")
    
    return output_obj

# Utilisation
if __name__ == "__main__":

    parser = argparse.ArgumentParser()
    parser.add_argument("INPUT", type=str)
    parser.add_argument("OUTPUT", type=str)
    parser.add_argument("--simplification", type=float, required=False)
    parser.add_argument("--extrusion", type=float, required=False)

    args = parser.parse_args()

    if args.simplification is None:
        args.simplification = 0.01
    if args.extrusion is None:
        args.extrusion = 0.03

    create_cardboard_mesh(
        args.INPUT,
        args.OUTPUT, 
        args.simplification,
        args.extrusion
    )