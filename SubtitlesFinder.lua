--[[
 Subtitles

 Copyright © 2009-2010 VideoLAN and AUTHORS
 
 Version: 1.2 [2013-03-03]

 Authors:
  - thePanz (Download-and-save feature, updates, installer script)
  - ale5000 (Based on the script made by Jean-Philippe André)
 Contributors:
  - Mederi (updated languages, plugin refactor)

 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston MA 02110-1301, USA.
--]]

dlg = nil

dialog_is_opened = false
dialog_is_hidden = false
update_title_needed = false
-- Common
website = nil
language = nil
main_text_input = nil
search_button = nil
load_button = nil
-- Dialog "Download subtitles"
subtitles_list = nil
subtitles_result = nil
-- Dialog "Load subtitles from url..."
type_text_input = nil

function descriptor()
	return {
				title = "Subtitles Finder";
				version = "1.1.0";
				author = "thePanz, ale5000";
				url = 'http://thepanz.netsons.org/post/vlc-and-opensubtitles-downloader';
				description = ""
						   .. "Find and get subtitles of movies from the internet."
               .. "<br /><br />Enabled online services:"
               .. "<ul>"
               .. "<li><a href='http://www.opensubtitles.org/'>www.OpenSubtitles.org</a></li>"
               .. "</ul>"
						   .. "This plugin is based on the script made by Jean-Philippe André";
				shortdesc = "Get the subtitles of movies from the internet, currently only from OpenSubtitles.org";
				capabilities = { "menu"; "input-listener"--[[; "meta-listener"]] }
			}
end

function menu()
	if not dialog_is_hidden then
		return { "Download", "Upload", "Load from url...", "About" }
	else
		return { "Show" }
	end
end

-- Function triggered when the extension is activated
function activate()
	vlc.msg.dbg(_VERSION)
	vlc.msg.dbg("[Subtitles] Activating")
	return true
end

-- Function triggered when the extension is deactivated
function deactivate()
	if dialog_is_opened then
		close()
	else
		reset_variables()
		dlg = nil
	end

	vlc.msg.dbg("[Subtitles] Deactivated")
	return true
end

function reset_variables()
	update_title_needed = false
	-- Common
	website = nil
	language = nil
	main_text_input = nil
	search_button = nil
	load_button = nil
	-- Dialog "Download subtitles"
	subtitles_list = nil
	subtitles_result = nil
	-- Dialog "Load subtitles from url..."
	type_text_input = nil
end

-- Function triggered when the dialog is closed
function close()
	dialog_is_opened = false
	dialog_is_hidden = false
	vlc.msg.dbg("[Subtitles] Closing dialog")
	reset_variables()

	if dlg ~= nil then dlg:delete() end
	dlg = nil
	return true
end

-- Current input changed
function input_changed()
	vlc.msg.dbg("[Subtitles] Input is changed")
	update_title()
end

-- Current input item meta changed
--[[function meta_changed()
end]]

function update_title()
	if dialog_is_hidden or not update_title_needed then return true end

	vlc.msg.dbg("[Subtitles] Updating title")
	local item = vlc.input.item()
	if item == nil then return false end

	local title = item:name()	-- It return the internal title or the filename if the first is missing
	if title ~= nil then
		title = string.gsub(title, "(.*)%.%w+$", "%1")	-- Removes file extension
		if title ~= "" then
			main_text_input:set_text(title)
			dlg:update()
			return true
		end
	end

	return false
end

function show_dialog_download()
	-- column, row, colspan, rowspan
	dlg:add_label("<right><b>Database: </b></right>", 1, 1, 1, 1)
	website = dlg:add_dropdown(2, 1, 3, 1)

	dlg:add_label("<right><b>Language: </b></right>", 1, 2, 1, 1)
	language = dlg:add_dropdown(2, 2, 3, 1)

	dlg:add_label("<right><b>Search: </b></right>", 1, 3, 1, 1)
	main_text_input = dlg:add_text_input("", 2, 3, 1, 1)
	search_button = dlg:add_button("Search", click_search, 3, 3, 1, 1)
	dlg:add_button("Hide", hide_dialog, 4, 3, 1, 1)

	for idx, ws in ipairs(websites) do
		website:add_value(ws.title, idx)
	end
	for idx, ws in ipairs(languages) do
		language:add_value(ws.title, idx)
	end

	update_title_needed = true
	update_title()

	dlg:update()
	return true
end

function show_dialog_upload()
	-- column, row, colspan, rowspan
	dlg:add_label("<right><b>Database: </b></right>", 1, 1, 1, 1)
	website = dlg:add_dropdown(2, 1, 4, 1)

-- FIXME: Link is NOT yet working
	dlg:add_label("<center><a href='http://www.opensubtitles.org/upload'>Upload to OpenSubtitles.org</a></center>", 1, 2, 2, 1)

	for idx, ws in ipairs(websites) do
		website:add_value(ws.title, idx)
	end

	dlg:update()
	return true
end

function show_dialog_load_url()
	-- column, row, colspan, rowspan
	dlg:add_label("<right><b>URL: </b></right>", 1, 1, 1, 1)
	main_text_input = dlg:add_text_input("", 2, 1, 3, 1)

	dlg:add_label("<right><b>Type: </b></right>", 1, 2, 1, 1)
	type_text_input = dlg:add_text_input("", 2, 2, 1, 1)
	dlg:add_label("&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;", 3, 2, 1, 1) -- Spacer
	load_button = dlg:add_button("Load", click_load_from_url_button, 4, 2, 1, 1)

	dlg:update()
	return true
end

function show_dialog_about()
	local data = descriptor()

	-- column, row, colspan, rowspan
	dlg:add_label("<center><b>" .. data.title .. " " .. data.version .. "</b></center>", 1, 1, 1, 1)
	dlg:add_html(data.description, 1, 2, 1, 1)

	dlg:update()
	return true
end

function sleep(sec)
	local t = vlc.misc.mdate()
	vlc.misc.mwait(t + sec*1000*1000)
end

function new_dialog(title)
	dlg = vlc.dialog(title)
end

function hide_dialog()
	dialog_is_hidden = true
	dlg:hide()
end

-- Function triggered when a element from the menu is selected
function trigger_menu(id)
	if dialog_is_hidden then
		if dlg == nil then
			vlc.msg.err("[Subtitles] Dialog pointer lost")
			close()
			return false;
		end

		dialog_is_hidden = false
		dlg:show()
		return true
	end
	if(dialog_is_opened) then close() end

	dialog_is_opened = true
	if id == 1 then
		new_dialog("Download subtitles")
		return show_dialog_download()
	elseif id == 2 then
		new_dialog("Upload subtitles")
		return show_dialog_upload()
	elseif id == 3 then
		new_dialog("Load subtitles from url...")
		return show_dialog_load_url()
	elseif id == 4 then
		new_dialog("About")
		return show_dialog_about()
	end

	vlc.msg.err("[Subtitles] Invalid menu id: "..id)
	return false
end

function click_search()
	vlc.msg.dbg("[Subtitles] Clicked search button from \"Download subtitles\" dialog")
	local search_term = main_text_input:get_text()
	if(search_term == "") then return false end

	local old_button_name = search_button:get_text()
	search_button:set_text("Wait...")
	if subtitles_list ~= nil then subtitles_list:clear() end
	dlg:update()

	subtitles_result = nil

	local idx = website:get_value()
	local idx2 = language:get_value()
	if idx < 1 or idx2 < 1 then vlc.msg.err("[Subtitles] Invalid index in dropdown") search_button:set_text(old_button_name) return false end

	local ws = websites[idx]
	local lang = languages[idx2]
	local url = ws.urlfunc(search_term, lang.tag)

	-- vlc.msg.info("[Subtitles] Url: '" .. url .. "'")
	local stream = vlc.stream(url)
	if stream == nil then vlc.msg.err("[Subtitles] The site of subtitles isn't reachable") search_button:set_text(old_button_name) return false end

	local reading = "blah"
	local xmlpage = ""
	while(reading ~= nil and reading ~= "") do
		reading = stream:read(65653)
		if(reading) then
			xmlpage = xmlpage .. reading
		end
	end
	if xmlpage == "" then search_button:set_text(old_button_name) return false end

	subtitles_result = ws.parsefunc(xmlpage)

	if subtitles_list == nil then
		subtitles_list = dlg:add_list(1, 4, 4, 1)
		load_button = dlg:add_button("Load selected subtitles", click_load_from_search_button, 1, 5, 4, 1)
	end

	if not subtitles_result then
		subtitles_result = {}
		subtitles_result[1]= { url = "-1" }
		subtitles_list:add_value("Nothing found", 1)
		search_button:set_text(old_button_name)
		dlg:update()
		return false
	end

	for idx, res in ipairs(subtitles_result) do
		if(not res.language or lang.tag == "all" or lang.tag == res.language) then
			subtitles_list:add_value("["..res.language.."]".."[#"..res.numfiles.."] "..res.name, idx)
		end
	end

	search_button:set_text(old_button_name)
	dlg:update()
	return true
end

function load_unknown_subtitles(url, language)
	vlc.msg.dbg("[Subtitles] Loading "..language.." subtitle: "..url)
	vlc.input.add_subtitle(url)
end

function load_subtitles_in_the_archive(dataBuffer, language)
	local buffer_length = dataBuffer:len()
	local files_found_in_the_compressed_file = 0
	local subtitles_found_in_the_compressed_file = 0
	local endIdx = 1
	local srturl, extension

	-- Find subtitles
	while(endIdx < buffer_length) do
		_, endIdx, srturl, extension = dataBuffer:find("<location>([^<]+)%.(%a%a%a?)</location>", endIdx)
		if(srturl == nil ) then break end

		--vlc.msg.dbg("[Subtitles] File found in the archive: " .. srturl .. extension)
		files_found_in_the_compressed_file = files_found_in_the_compressed_file + 1
		srturl = string.gsub(srturl, "^(%a%a%a)://", "%1://http://")

		if(extension == "ass" or extension == "ssa" or extension == "srt" or extension == "smi" or extension == "sub" or extension == "rt" or extension == "txt" or extension == "mpl") then
			subtitles_found_in_the_compressed_file = subtitles_found_in_the_compressed_file + 1
			vlc.msg.dbg("[Subtitles] Loading "..language.." subtitle: "..srturl)
      
            save_subtitle(srturl, extension, language)
      
			vlc.input.add_subtitle(srturl.."."..extension)
		end
	end
	vlc.msg.info("[Subtitles] Files found in the compressed file: "..files_found_in_the_compressed_file)
	vlc.msg.info("[Subtitles] Subtitles found in the compressed file: "..subtitles_found_in_the_compressed_file)

	if(subtitles_found_in_the_compressed_file > 0) then return true end

	vlc.msg.warn("[Subtitles] No subtitles found in the compressed file")
	return false
end

function save_subtitle(url, extension, language)
  
  -- vlc.msg.info(url)
  -- vlc.msg.info(extension)
  -- vlc.msg.info(language)
  -- save2(url.."."..extension)
  
  local stream = vlc.stream(url.."."..extension)
	if stream == nil then
    vlc.msg.err("[Subtitle-download] The site of subtitles isn't reachable")
    return false
  end

	local data = stream:read(2048)
	if(data == nil) then
		vlc.msg.info("[Subtitle-download] Subtitle is NIL: "..url.."."..extension)
	else
		vlc.msg.info("[Subtitle-download] Buffering: "..url.."."..extension)
		local dataBuffer = ""
		while(data ~= nil and data ~= "") do
			dataBuffer = dataBuffer..data
			data = stream:read(8192)
		end
    -- vlc.msg.info("dataBuffer: "..dataBuffer)
    
    
    local item = vlc.input.item()
    if(item ~= nil) then
      local name = item:uri()
      -- vlc.msg.info("NAME: "..name)
      name = vlc.strings.decode_uri(string.gsub(name, "file:///", ""))
      vlc.msg.info("[Subtitle-download] saving subtitle to: "..name.."."..language.."."..extension)
      local fsout = assert(io.open(name.."."..language.."."..extension, "w"))
      fsout:write(dataBuffer)
      assert(fsout:close())
    end

	end

end

function parse_archive(url, language)
	if url == "-1" then vlc.msg.dbg("[Subtitles] Dummy result") return true end

	local stream = vlc.stream(url)
	if stream == nil then vlc.msg.err("[Subtitles] The site of subtitles isn't reachable") return false end
	stream:addfilter("zip,stream_filter_rar")

	local data = stream:read(2048)
	if(data == nil or data:find("<?xml version", 1, true) ~= 1) then
		vlc.msg.info("[Subtitles] Type: RAR or unknown file")
		load_unknown_subtitles(url, language)
	else
		vlc.msg.info("[Subtitles] Type: ZIP file")
		local dataBuffer = ""
		while(data ~= nil and data ~= "") do
			vlc.msg.dbg("Buffering...")
			dataBuffer = dataBuffer..data
			data = stream:read(8192)
		end
		load_subtitles_in_the_archive(dataBuffer, language)
	end
	--vlc.msg.dbg("[Subtitles] Subtitle data: "..dataBuffer)

	return true
end

function click_load_from_search_button()
	vlc.msg.dbg("[Subtitles] Clicked load button from \"Download subtitles\" dialog")
	if(not vlc.input.is_playing()) then
		vlc.msg.warn("[Subtitles] You cannot load subtitles if you aren't playing any file")
		return true
	end
	local old_button_name = load_button:get_text()
	load_button:set_text("Wait...")
	dlg:update()

	local selection = subtitles_list:get_selection()
	local index, name

	for index, name in pairs(selection) do
		vlc.msg.dbg("[Subtitles] Selected the item "..index.." with the name: "..name)
		vlc.msg.dbg("[Subtitles] URL: "..subtitles_result[index].url)

		parse_archive(subtitles_result[index].url, subtitles_result[index].language) -- ZIP, RAR or unknown file
	end

	load_button:set_text(old_button_name)
	dlg:update()
	return true
end

function click_load_from_url_button()
	vlc.msg.dbg("[Subtitles] Clicked load button in \"Load subtitles from url...\" dialog")
	if(not vlc.input.is_playing()) then
		vlc.msg.warn("[Subtitles] You cannot load subtitles if you aren't playing any file")
		return true
	end
	local old_button_name = load_button:get_text()
	load_button:set_text("Wait...")
	type_text_input:set_text("")
	dlg:update()

	local url_to_load = main_text_input:get_text()
	if(url_to_load == "") then return false end
	vlc.msg.dbg("[Subtitles] URL: "..url_to_load)

	local _, ext_pos, extension = url_to_load:find("%.(%a%a%a?)", -4)

	if(ext_pos == url_to_load:len()) then
		type_text_input:set_text(extension)
		if(extension == "ass" or extension == "ssa" or extension == "srt" or extension == "smi" or extension == "sub" or extension == "rt" or extension == "txt" or extension == "mpl") then
			load_button:set_text(old_button_name)
			dlg:update()
			return vlc.input.add_subtitle(url_to_load)
		end
	end

	local result = parse_archive(url_to_load, "")
	if not result then
		vlc.msg.info("[Subtitles] Waiting 5 seconds before retry...")
		sleep(5)
		result = parse_archive(url_to_load, "")
	end

	load_button:set_text(old_button_name)
	dlg:update()
	return result
end



-- XML Parsing
function parseargs(s)
	local arg = {}
	string.gsub(s, "(%w+)=([\"'])(.-)%2", function (w, _, a)
		arg[w] = a
	end)
	return arg
end

function collect(s)
	local stack = {}
	local top = {}
	table.insert(stack, top)
	local ni,c,label,xarg, empty
	local i, j = 1, 1
	while true do
		ni,j,c,label,xarg, empty = string.find(s, "<(%/?)([%w:]+)(.-)(%/?)>", i)
		if not ni then break end
		local text = string.sub(s, i, ni-1)
		if not string.find(text, "^%s*$") then
			table.insert(top, text)
		end
		if empty == "/" then -- empty element tag
			table.insert(top, {label=label, xarg=parseargs(xarg), empty=1})
		elseif c == "" then -- start tag
			top = {label=label, xarg=parseargs(xarg)}
			table.insert(stack, top) -- new level
		else -- end tag
			local toclose = table.remove(stack) -- remove top
			top = stack[#stack]
			if #stack < 1 then
				error("nothing to close with "..label)
			end
			if toclose.label ~= label then
				error("trying to close "..toclose.label.." with "..label)
			end
			table.insert(top, toclose)
		end
		i = j+1
	end
	local text = string.sub(s, i)
	if not string.find(text, "^%s*$") then
		table.insert(stack[#stack], text)
	end
	if #stack > 1 then
		error("unclosed "..stack[stack.n].label)
	end
	return stack[1]
end


--[[
		Websites configurations
]]--

-- OpenSubtitles.org
-- This function uses first version of OS API. It will probably fail in the future.
-- We'll need a XML-RPC key btw
-- See: http://trac.opensubtitles.org/projects/opensubtitles/wiki/XMLRPC
function urlOpenSub(search_term,lang)
	-- base = "http://api.opensubtitles.org/xml-rpc"
	-- lang = "eng"

	if lang == "all" then
		lang ="en"
	end 
	base = "http://api.opensubtitles.org/"..lang.."/search/"
	-- if(lang) then base = base .. "sublanguageid-" .. lang .. "/"
	search_term = string.gsub(search_term, "%%", "%%37")
	search_term = string.gsub(search_term, " ", "%%20")
	return base .. "moviename-" .. search_term .. "/simplexml"
	-- http://api.opensubtitles.org/en/search/moviename- .. search_term .. /simplexml
end

function parseOpenSub(xmltext)
	vlc.msg.dbg("[Subtitles] Parsing XML data...")
	local xmltext = string.gsub(xmltext, "<%?xml version=\"1%.0\" encoding=\"utf-8\"%?>", "")
	local xmldata = collect(xmltext)
	for a,b in pairs(xmldata) do
		if type(b) == "table" then
			if b.label == "search" then
				xmldata = b
				break
			end
		end
	end


	if xmldata == nil then return nil end

	-- Subtitles information data
	local subname = {}
	local sub_movie = {}
	local suburl = {}
	local sublang = {}
	local sub_language = {}
	local subformat = {}
	local subfilenum = {}
	local subnum = 1
	local baseurl = ""

	-- Let's browse iteratively the 'xmldata' tree
	-- OK, the variables' names aren't explicit enough, but just remember a couple
	-- a,b contains the index (a) and the data (b) of the table, which might also be a table
	for a,b in pairs(xmldata) do
		if type(b) == "table" then
			if b.label == "results" then
				for c,d in pairs(b) do
					if type(d) == "table" then
						if d.label == "subtitle" then
							for e,f in pairs(d) do
								if type(f) == "table" then
									if f.label == "releasename" then
										if f[1] ~= nil then subname[subnum] = f[1]
										else subname[subnum] = "" end
									elseif f.label == "movie" then
										if f[1] ~= nil then sub_movie[subnum] = f[1]
										else sub_movie[subnum] = "" end
									elseif f.label == "download" then
										if f[1] ~= nil then suburl[subnum] = f[1]
										else suburl[subnum] = "" end
									elseif f.label == "iso639" then	-- language
										if f[1] ~= nil then sublang[subnum] = f[1]
										else sublang[subnum] = "" end
									elseif f.label == "language" then	-- language	-- not use yet
										if f[1] ~= nil then sub_language[subnum] = f[1]
										else sub_language[subnum] = "" end
									elseif f.label == "format" then
										if f[1] ~= nil then subformat[subnum] = f[1]
										else subformat[subnum] = "" end
									elseif f.label == "files" then
										if f[1] ~= nil then subfilenum[subnum] = f[1]
										else subfilenum[subnum] = "" end
									end
								end
							end
							subnum = subnum + 1
						end
					end
				end
			elseif b.label == "base" then
				baseurl = b[1]
			end
		end
	end

	if subnum <= 1 then
		return nil
	end

	ret = {}

	for i = 1,(subnum - 1) do
		fullURL = baseurl .. "/" .. suburl[i]
		
		realName = string.gsub( subname[i], "<..CDATA.", "" )
		realName = string.gsub( realName, "..>", "" )

		if realName == "" then
			realName = string.gsub( sub_movie[i], "<..CDATA.", "" )
			realName = string.gsub( realName, "..>", "" )
		end

		ret[i] = { name = realName,
			   url = fullURL,
		           language = sublang[i],
			   extension = ".zip" ,
			   numfiles = subfilenum[i]  
}

		vlc.msg.dbg("[Subtitles] Found subtitle " .. i .. ": ")
		vlc.msg.dbg(realName)
		vlc.msg.dbg(fullURL)
	end

	return ret
end

-- These tables must be after all function definitions
websites = {
	{ title = "OpenSubtitles.org",
	  urlfunc = urlOpenSub,
	  parsefunc = parseOpenSub } --[[;
	{ title = "Fake (OS)",
	  urlfunc = url2,
	  parsefunc = parse2 }]]
}

-- ISO639 lang codes: 
-- For Opensubtitles refer to: http://www.opensubtitles.org/addons/export_languages.php
languages = {
   { title = "-Any Language-", tag = "all" },
   { title = "Albanian [sq]", tag = "sq" },
   { title = "Arabic [ar]", tag = "ar" },
   { title = "Armenian [hy]", tag = "hy" },
   { title = "Basque [eu]", tag = "eu" },
   { title = "Bengali [bn]", tag = "bn" },
   { title = "Bosnian [bs]", tag = "bs" },
   { title = "Brazilian [pb]", tag = "pb" },
   { title = "Breton [br]", tag = "br" },
   { title = "Bulgarian [bg]", tag = "bg" },
   { title = "Burmese [my]", tag = "my" },
   { title = "Catalan [ca]", tag = "ca" },
   { title = "Chinese [zh]", tag = "zh" },
   { title = "Croation [hr]", tag = "hr" },
   { title = "Czech [cs]", tag = "cs" },
   { title = "Danish [da]", tag = "da" },
   { title = "Dutch [nl]", tag = "nl" },
   { title = "English [en]", tag = "en" },
   { title = "Esperanto [eo]", tag = "eo" },
   { title = "Estonian [et]", tag = "et" },
   { title = "Finnish [fi]", tag = "fi" },
   { title = "French [fr]", tag = "fr" },
   { title = "Galician [gl]", tag = "gl" },
   { title = "Georgian [ka]", tag = "ka" },
   { title = "German [de]", tag = "de" },
   { title = "Greek [el]", tag = "el" },
   { title = "Hebrew [he]", tag = "he" },
   { title = "Hindi [hi]", tag = "hi" },
   { title = "Hungarian [hu]", tag = "hu" },
   { title = "Icelandic [is]", tag = "is" },
   { title = "Indonesian [id]", tag = "id" },
   { title = "Italina [it]", tag = "it" },
   { title = "Japanese [ja]", tag = "ja" },
   { title = "Kazakh [kk]", tag = "kk" },
   { title = "Khmer [km]", tag = "km" },
   { title = "Korean [ko]", tag = "ko" },
   { title = "Latvian [lv]", tag = "lv" },
   { title = "Lithuanian [lt]", tag = "lt" },
   { title = "Luxembourgish [lb]", tag = "lb" },
   { title = "Macedonian [mk]", tag = "mk" },
   { title = "Malay [ms]", tag = "ms" },
   { title = "Malayalam [ml]", tag = "ml" },
   { title = "Mongolian [mn]", tag = "mn" },
   { title = "Norwegian [no]", tag = "no" },
   { title = "Occitan [oc]", tag = "oc" },
   { title = "Polish [pl]", tag = "pl" },
   { title = "Portuguese [pt]", tag = "pt" },
   { title = "Romanian [ro]", tag = "ro" },
   { title = "Russian [ru]", tag = "ru" },
   { title = "Serbian [sr]", tag = "sr" },
   { title = "Sinhalese [si]", tag = "si" },
   { title = "Slovak [sk]", tag = "sk" },
   { title = "Slovenian [sl]", tag = "sl" },
   { title = "Spanish [es]", tag = "es" },
   { title = "Swahili [sw]", tag = "sw" },
   { title = "Swedish [sv]", tag = "sv" },
   { title = "Tagalog [tl]", tag = "tl" },
   { title = "Telugu [te]", tag = "te" },
   { title = "Thai [th]", tag = "th" },
   { title = "Turkish [tr]", tag = "tr" },
   { title = "Ukrainian [uk]", tag = "uk" },
   { title = "Urdu [ur]", tag = "ur" },
   { title = "Vietnamese [vi]", tag = "vi" }
}

