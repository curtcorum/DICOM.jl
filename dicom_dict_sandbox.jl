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
    Pkg.add([
        Pkg.PackageSpec(path=local_DICOM),
    ])
    using NativeFileDialog, Dates, DelimitedFiles, DICOM
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

# ╔═╡ 6aac6ac2-1788-41df-85fa-4d0e8a392f17
data_path = joinpath( homedir(), "src/DICOM.jl/dicts")

# ╔═╡ effbbc5f-81db-4d43-81d9-5448b6357cf5
now()

# ╔═╡ 9226cc3a-5b98-4eb2-baa7-1d6cfddd7739
#This is the dicom dictioonary with MR specifics for GE
#my_dict_file = pick_file( data_path)
my_dict_file = "/home/curt/src/DICOM.jl/dicts/gems/gems-dicom-dict.txt"

# ╔═╡ b8f72b73-a0ec-42b0-99af-d02d5b8cd2fb
my_raw_dict = readdlm(my_dict_file, '\t', String, '\n'; header=false, comments=true, comment_char='#')

# ╔═╡ 1cffb689-518a-4ac1-8c89-aa6d14f70916
# Reformat into DICOM.dcm_dict format
begin
	my_dcm_dict = Dict{Tuple{UInt16, UInt16}, Vector{Any}}()
	for row in axes( my_raw_dict, 1)
		#println( row, " ", col, " ", my_raw_dict[row, col])
		# ignore or skip "xx" for now?
		dcm_tag = parse( UInt32, replace( my_raw_dict[row, 1], '(' => "", ')' => "", ',' => "", 'x' => "f"), base=16)
		
		#dcm_tag_l = parse( UInt16, string( tag_low), base=16)
		#dcm_tag_tmp = (dcm_tag_h, dcm_tag_l)
		#my_dcm_dict[dcm_tag_tmp] = [Symbol( name), vr, vm]
		println( row, "\t", string( dcm_tag, base=16, pad=8), "\t", my_raw_dict[row, 3])
	end
end

# ╔═╡ 74c5d6fd-3206-4901-b5ea-3e752fe84418
typeof( my_dcm_dict)

# ╔═╡ e22fbfcb-5f39-4e9a-8aed-a6f1b87b4f27
my_dcm_dict

# ╔═╡ a407726f-b5e7-4672-bf91-732c75ae4392
#This is the default dictionary for DICOM.jl
dcm_dict_default = DICOM.dcm_dict

# ╔═╡ 437ede2c-c649-48fd-af98-346f46468204
# ╠═╡ show_logs = false
# ╠═╡ disabled = true
#=╠═╡
# loop through dcm_dict_default and compare to my_dcm_dict
for (key, value) in dcm_dict_default
	def_name = value[1]
	if haskey( my_dcm_dict, key)
		my_name = (my_dcm_dict[key])[1]
		if def_name == my_name
			# nothing
		else
			println( key, " NOT EQUAL ", def_name, " ", my_name)
		end
	else
		println( key, " MISSING ", def_name)
	end
end
  ╠═╡ =#

# ╔═╡ e418bf76-8bfc-499c-b77a-05c96619a347
# ╠═╡ show_logs = false
# ╠═╡ disabled = true
#=╠═╡
# loop through  my_dcm_dict and compare to dcm_dict_default
for (key, value) in my_dcm_dict
	my_name = value[1]
	if haskey( dcm_dict_default, key)
		def_name = (dcm_dict_default[key])[1]
		if def_name == my_name
			# nothing
		else
			println( key, " NOT EQUAL ", my_name, " ", def_name)
		end
	else
		println( key, " MISSING ", my_name)
	end
end
  ╠═╡ =#

# ╔═╡ 0fb7ed85-a4f0-481d-bb95-591a4b36ec9a
# ╠═╡ disabled = true
#=╠═╡
dcm_dict_plus_my = copy( dcm_dict_default);
  ╠═╡ =#

# ╔═╡ 973c001d-a94b-4085-a4f8-3c7c2549d02b
vr_plus_my = Dict( (0x0000, 0x0000) => "")

# ╔═╡ 3ded8e96-8193-4f1b-bd93-bdccb18c07bb
# ╠═╡ disabled = true
#=╠═╡
# loop through  my_dcm_dict and append to dcm_dict_default if key missing
for (key, value) in my_dcm_dict
	if haskey( dcm_dict_default, key)
		# nothing
	else
		vr_plus_my[key] = (my_dcm_dict[key])[2]
		dcm_dict_plus_my[key] =  (my_dcm_dict[key])[1:3]
	end
end
  ╠═╡ =#

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
# ╠═6aac6ac2-1788-41df-85fa-4d0e8a392f17
# ╠═effbbc5f-81db-4d43-81d9-5448b6357cf5
# ╠═9226cc3a-5b98-4eb2-baa7-1d6cfddd7739
# ╠═b8f72b73-a0ec-42b0-99af-d02d5b8cd2fb
# ╠═1cffb689-518a-4ac1-8c89-aa6d14f70916
# ╠═74c5d6fd-3206-4901-b5ea-3e752fe84418
# ╠═e22fbfcb-5f39-4e9a-8aed-a6f1b87b4f27
# ╠═a407726f-b5e7-4672-bf91-732c75ae4392
# ╠═437ede2c-c649-48fd-af98-346f46468204
# ╠═e418bf76-8bfc-499c-b77a-05c96619a347
# ╠═0fb7ed85-a4f0-481d-bb95-591a4b36ec9a
# ╠═973c001d-a94b-4085-a4f8-3c7c2549d02b
# ╠═3ded8e96-8193-4f1b-bd93-bdccb18c07bb
# ╠═66b43451-4382-4aa8-8291-b9e8104514f3
# ╠═5cca6bcb-0333-4fca-89bd-4bcc7921cd79
# ╠═9b0336e1-83b7-43d8-bcde-a9ada0f7e964
