{
	"patcher" : 	{
		"fileversion" : 1,
		"appversion" : 		{
			"major" : 8,
			"minor" : 3,
			"revision" : 2,
			"architecture" : "x64",
			"modernui" : 1
		}
,
		"classnamespace" : "box",
		"rect" : [ -166.0, -946.0, 1169.0, 699.0 ],
		"bglocked" : 0,
		"openinpresentation" : 0,
		"default_fontsize" : 12.0,
		"default_fontface" : 0,
		"default_fontname" : "Arial",
		"gridonopen" : 1,
		"gridsize" : [ 15.0, 15.0 ],
		"gridsnaponopen" : 1,
		"objectsnaponopen" : 1,
		"statusbarvisible" : 2,
		"toolbarvisible" : 1,
		"lefttoolbarpinned" : 0,
		"toptoolbarpinned" : 0,
		"righttoolbarpinned" : 0,
		"bottomtoolbarpinned" : 0,
		"toolbars_unpinned_last_save" : 0,
		"tallnewobj" : 0,
		"boxanimatetime" : 200,
		"enablehscroll" : 1,
		"enablevscroll" : 1,
		"devicewidth" : 0.0,
		"description" : "",
		"digest" : "",
		"tags" : "",
		"style" : "",
		"subpatcher_template" : "s4m",
		"assistshowspatchername" : 0,
		"boxes" : [ 			{
				"box" : 				{
					"id" : "obj-22",
					"maxclass" : "message",
					"numinlets" : 2,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"patching_rect" : [ 127.000002026557922, 70.999997437000275, 104.0, 22.0 ],
					"text" : "readarray :display"
				}

			}
, 			{
				"box" : 				{
					"id" : "obj-16",
					"maxclass" : "message",
					"numinlets" : 2,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"patching_rect" : [ 79.000002026557922, 70.999997437000275, 35.0, 22.0 ],
					"text" : "clear"
				}

			}
, 			{
				"box" : 				{
					"id" : "obj-5",
					"linecount" : 2,
					"maxclass" : "message",
					"numinlets" : 2,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"patching_rect" : [ 96.60000205039978, 110.999997496604919, 197.799997508525848, 35.0 ],
					"text" : "127 64 90 64 127 64 80 64 60 61 62 63 64 65 66 67 0 0 0 0 0 0 0 0"
				}

			}
, 			{
				"box" : 				{
					"cellchars" : 4,
					"cellheight" : 20,
					"cellsperbar" : 16,
					"cellsperbeat" : 3,
					"cellwidth" : 29,
					"color" : [ 1.0, 1.0, 1.0, 1.0 ],
					"columns" : 8,
					"floatdigits" : 2,
					"fontsize" : 11.0,
					"id" : "obj-9",
					"maxclass" : "s4m.grid",
					"notenames" : 1,
					"noterow" : 2,
					"numinlets" : 1,
					"numoutlets" : 1,
					"outlettype" : [ "int" ],
					"patching_rect" : [ 79.000002026557922, 167.333330571651459, 232.0, 80.0 ],
					"printzero" : 1,
					"rotate" : 0,
					"rows" : 4
				}

			}
 ],
		"lines" : [ 			{
				"patchline" : 				{
					"destination" : [ "obj-9", 0 ],
					"source" : [ "obj-16", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-9", 0 ],
					"midpoints" : [ 136.500002026557922, 98.999997437000275, 88.000002026557922, 98.999997437000275, 88.500002026557922, 156.999997437000275 ],
					"source" : [ "obj-22", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-9", 0 ],
					"source" : [ "obj-5", 0 ]
				}

			}
 ],
		"dependency_cache" : [ 			{
				"name" : "s4m.mxo",
				"type" : "iLaX"
			}
 ],
		"autosave" : 0
	}

}
