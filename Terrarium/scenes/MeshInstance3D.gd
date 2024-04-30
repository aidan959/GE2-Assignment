extends MeshInstance3D

func _ready():
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var radius = 2.0
	var num_points = 32
	st.add_vertex(Vector3(0, 0, 0)) 

	for i in range(num_points + 1):
		var angle = i * 2.0 * PI / num_points
		st.add_vertex(Vector3(cos(angle) * radius, 0, sin(angle) * radius))
		if i > 0:
			st.add_index(0)
			st.add_index(i)
			st.add_index(i + 1)

	st.generate_normals()
	var mesh = ArrayMesh.new()
	st.commit(mesh)
	self.mesh = mesh
