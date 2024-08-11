### A Pluto.jl notebook ###
# v0.19.45

using Markdown
using InteractiveUtils

# ╔═╡ 4eeb1fa3-df83-427f-92bf-51477ae3e194
# Loads local version of DICOM
# https://plutojl.org/en/docs/packages-advanced
begin
	local_DICOM = pwd()
    import Pkg
    # activate a temporary environment
    Pkg.activate(mktempdir())
	using NativeFileDialog, Dates, DelimitedFiles
    Pkg.add([
        Pkg.PackageSpec(path=local_DICOM),
    ])
    using DICOM
end

# ╔═╡ 9828cbdb-09f0-4708-98a8-193f57c7cbe7
print( "Julia v", VERSION)

# ╔═╡ 562e366e-b576-46a7-bd3e-cc213b969daa
# ╠═╡ show_logs = false
# ╠═╡ disabled = true
#=╠═╡
versioninfo()
  ╠═╡ =#

# ╔═╡ 29e1f787-c0f8-4d64-aef1-eaa5c69311d0
pkgversion( DICOM)

# ╔═╡ 9ebb48fd-bf79-47a9-bbe2-7de11ea2e096
ENV["USERNAME"]

# ╔═╡ 33680691-25fe-4811-a088-374e1beae63a
pwd()

# ╔═╡ effbbc5f-81db-4d43-81d9-5448b6357cf5
now()

# ╔═╡ 1cffb689-518a-4ac1-8c89-aa6d14f70916
# Reformat into DICOM.dcm_dict format
begin
	my_dcm_dict = Dict{Tuple{UInt16, UInt16}, Vector{Any}}()
	my_dict_file = joinpath( pwd(), "dicts/external-dicom-dict.txt")
	my_raw_dict = readdlm(my_dict_file, '\t', String, '\n'; header=false, comments=true, comment_char='#');
	for row in axes( my_raw_dict, 1)
		# ignore or skip "xx" for now?
		dcm_tag_raw = string( parse( UInt32, replace( my_raw_dict[row, 1], '(' => "", ')' => "", ',' => "", 'x' => "f"), base=16), base=16, pad=8)
		bytes_array = hex2bytes( dcm_tag_raw)
		dcm_tag_l = parse( UInt16, bytes2hex( bytes_array[3:4]), base=16)
		dcm_tag_h = parse( UInt16, bytes2hex( bytes_array[1:2]), base=16)
		dcm_tag = (dcm_tag_h, dcm_tag_l)
		vr =  my_raw_dict[row, 2]
		name =  my_raw_dict[row, 3]
		vm =  my_raw_dict[row, 4]
		#println( row, "\t", dcm_tag, "\t", vr, "\t", name, "\t", vm )
		my_dcm_dict[dcm_tag] = [Symbol( name), vr, vm]
	end
end

# ╔═╡ 74c5d6fd-3206-4901-b5ea-3e752fe84418
typeof( my_dcm_dict)

# ╔═╡ e22fbfcb-5f39-4e9a-8aed-a6f1b87b4f27
my_dcm_dict

# ╔═╡ a407726f-b5e7-4672-bf91-732c75ae4392
#This is the default dictionary for DICOM.jl
dcm_dict_default = DICOM.dcm_dict

# ╔═╡ 4c827956-4632-4982-8356-409417bcd712
for (key, value) in dcm_dict_default
	#println( key)
	def_name = value[1]
	if haskey( my_dcm_dict, key)
		#println( key, " PRESENT ", def_name)
	else
		println( key, " MISSING ", def_name)
	end
end

# ╔═╡ 2a985def-3477-434d-96b8-3097564ccd91
for (key, value) in my_dcm_dict
	#println( key)
	def_name = value[1]
	if haskey( dcm_dict_default, key)
		#println( key, " PRESENT ", def_name)
	else
		println( key, " MISSING ", def_name)
	end
end

# ╔═╡ 973c001d-a94b-4085-a4f8-3c7c2549d02b
vr_plus_my = Dict( (0x0000, 0x0000) => "")

# ╔═╡ 66b43451-4382-4aa8-8291-b9e8104514f3
# ╠═╡ disabled = true
#=╠═╡
#will this allow dot addressing? it seems not... *** CAC 240805
DICOM.dcm_dict = dcm_dict_plus_my
  ╠═╡ =#

# ╔═╡ 5cca6bcb-0333-4fca-89bd-4bcc7921cd79
# ╠═╡ disabled = true
#=╠═╡
# Pick a top level forder to scan for didcom directories

dicom_folder = pick_folder( data_path)
  ╠═╡ =#

# ╔═╡ 9b0336e1-83b7-43d8-bcde-a9ada0f7e964
# ╠═╡ disabled = true
#=╠═╡
#simshow( Float32.( dcm_data_test.PixelData))
simshow( dcm_data_test.PixelData; γ=2)
  ╠═╡ =#

# ╔═╡ Cell order:
# ╠═9828cbdb-09f0-4708-98a8-193f57c7cbe7
# ╠═562e366e-b576-46a7-bd3e-cc213b969daa
# ╠═4eeb1fa3-df83-427f-92bf-51477ae3e194
# ╠═29e1f787-c0f8-4d64-aef1-eaa5c69311d0
# ╠═9ebb48fd-bf79-47a9-bbe2-7de11ea2e096
# ╠═33680691-25fe-4811-a088-374e1beae63a
# ╠═effbbc5f-81db-4d43-81d9-5448b6357cf5
# ╠═1cffb689-518a-4ac1-8c89-aa6d14f70916
# ╠═74c5d6fd-3206-4901-b5ea-3e752fe84418
# ╠═e22fbfcb-5f39-4e9a-8aed-a6f1b87b4f27
# ╠═a407726f-b5e7-4672-bf91-732c75ae4392
# ╠═4c827956-4632-4982-8356-409417bcd712
# ╠═2a985def-3477-434d-96b8-3097564ccd91
# ╠═973c001d-a94b-4085-a4f8-3c7c2549d02b
# ╠═66b43451-4382-4aa8-8291-b9e8104514f3
# ╠═5cca6bcb-0333-4fca-89bd-4bcc7921cd79
# ╠═9b0336e1-83b7-43d8-bcde-a9ada0f7e964
