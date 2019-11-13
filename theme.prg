clear
set path to home() + "FFC\" additive
#INCLUDE "Registry.H"

set procedure to color.prg additive
set procedure to json.prg additive

setTheme("Dark (Visual Studio)")
*setTheme("Github")
*seeAllThemes()
return 


procedure setTheme
	lparameters cTheme
	with createobject("Theme")
		if .execute(cTheme)
			.SetScreenColors()
			SYS(3056)
		endif 
	endwith 
endproc 

procedure seeAllThemes 
	with createobject("Theme")
		dimension aOptions[9]
		
		aOptions[1] = "Dracula"
		aOptions[2] = "Light (Visual Studio)"
		aOptions[3] = "Dark (Visual Studio)"
		aOptions[4] = "Github"
		aOptions[5] = "One Dark Pro"
		aOptions[6] = "Field Lights"
		aOptions[7] = "MacOS Classic"
		aOptions[8] = "MacOS Modern Dark"	
		aOptions[9] = "One Monokai"
		
		for nVar = 1 to alen(aOptions) 
			.execute(aOptions[nvar])
			.SetScreenColors()
			SYS(3056)
			wait window aOptions[nvar]
		endfor 
	endwith 
endproc 

define class Theme as Custom
	
	oJson = .null.
	oColor = .null.
	
	cPathTheme = "themes"
	dimension aEditorColors[1, 2] 
	
	cVFPOptPath = VFP_OPTIONS_KEY1 + _VFP.VERSION + VFP_OPTIONS_KEY2
	
	procedure init
		this.oJson = createobject("Json")
		this.oColor = createobject("Color")
	endproc 
	
	procedure execute
		lparameters cFileTheme
		
		local cEntry, cTheme, cEditorForeGround, cEditorBackGround, cColorToRegister, cForeGround, cStyle, cEntryStyle
		local oJsonDecoded, oColors
		local i
		  
		cTheme = this.getTheme(cFileTheme)

		oJsonDecoded = this.oJson.Decode(cTheme)

		if isnull(oJsonDecoded)
			return .F.
		endif

		oColors = oJsonDecoded.get("colors", .null.)
		
		cEditorForeGround = oColors.get("editor_foreground", "")
		cEditorBackGround = oColors.get("editor_background", "")
		
		cColorToRegister = this.oColor.Hex2Rgb2Register(cEditorForeGround, cEditorBackGround)
		
		if cColorToRegister = "error"
			return .F.
		endif 
		
		this.addInArray("EditorNormalColor", cColorToRegister)
		this.addInArray("EditorOperatorColor", cColorToRegister)		
		this.addInArray("EditorVariableColor", cColorToRegister)

		oTokenColors = oJsonDecoded.get("tokenColors", .null.)
		for each oToken in oTokenColors.array
			cForeGround = ""
			uScope = oToken.get("scope")
			if vartype(uScope) = "C"
				oSettings = oToken.get("settings")
				for i=1 to getwordcount(uScope, ",")
					this.getColors(alltrim(getwordnum(uScope, i, ",")), oSettings, @cForeGround, @cEntry, @cStyle, @cEntryStyle)
					if !empty(cForeGround)
						cColorToRegister = this.oColor.Hex2Rgb2Register(cForeGround, cEditorBackGround)
						if cColorToRegister = "error"
							return .F.
						endif 			
									
						this.addInArray(cEntry, cColorToRegister)
					endif 
					
					if !empty(cStyle)								
						this.addInArray(cEntryStyle, cStyle)
					endif 
				next 	
			else
				if vartype(uScope) = "O" and pemstatus(uScope, "Array", 5)
					oSettings = oToken.get("settings")
					for each scope in uScope.array	
						for i=1 to getwordcount(scope, ",")
							this.getColors(alltrim(getwordnum(scope, i, ",")), oSettings, @cForeGround, @cEntry, @cStyle, @cEntryStyle)		
							
							if !empty(cForeGround)
								if cColorToRegister = "error"
									return .F.
								endif 							
								
								cColorToRegister = this.oColor.Hex2Rgb2Register(cForeGround, cEditorBackGround)
								this.addInArray(cEntry, cColorToRegister)
							endif 
							
							if !empty(cStyle)								
								this.addInArray(cEntryStyle, cStyle)
							endif 						
						next 	
					next
					 	
				endif 
			endif
		next
		
		this.Register()
	endproc 
	
	procedure getColors
		lparameters cScope, oSettings, cForeGround, cEntry, cStyle, cEntryStyle
		
		local cFontStyle
		cForeGround = ""					
		cEntry = ""	
		cStyle = ""	
		cEntryStyle = ""
		
		cScope = lower(cScope)
		
		do case
			case cScope == "string" or cScope == "string.quoted"
				cForeGround = oSettings.get("foreground")
				cFontStyle = oSettings.get("fontStyle", "")
				cEntry = "EditorStringColor"
				cEntryStyle = "EditorStringStyle"
				
			case cScope == "comment"
				cForeGround = oSettings.get("foreground")
				cFontStyle = oSettings.get("fontStyle", "")
				cEntry = "EditorCommentColor"
				cEntryStyle = "EditorCommentStyle"

			case cScope == "keyword"
				cForeGround = oSettings.get("foreground")
				cFontStyle = oSettings.get("fontStyle", "")
				cEntry = "EditorKeywordColor"
				cEntryStyle = "EditorKeywordStyle"
				
			case cScope == "constant" or cScope == "constant.numeric"
				cForeGround = oSettings.get("foreground")
				cFontStyle = oSettings.get("fontStyle", "")
				cEntry = "EditorConstantColor"
				cEntryStyle = "EditorConstantStyle"
				
			case cScope == "keyword.operator"
				cForeGround = oSettings.get("foreground")
				cFontStyle = oSettings.get("fontStyle", "")
				cEntry = "EditorOperatorColor"
				cEntryStyle = "EditorOperatorStyle"
				
		endcase	
		
		if !empty(cForeGround)
			do case
				case empty(cFontStyle)
					cStyle = "-1"
				case lower(cFontStyle) = "normal"
					cStyle = "0"
				case lower(cFontStyle) = "bold"
					cStyle = "1"
				case lower(cFontStyle) = "italic"
					cStyle = "2"										
			endcase 
		endif 
			
	endproc 
	
	procedure Register
		local oRegApi
		local i
		local cRegKey

		oRegApi = newobject("Registry", home() + "FFC\Registry.VCX")	
			
		for i=1 to alen(this.aEditorColors, 1)
			oRegApi.SetRegKey(this.aEditorColors[i, 1], this.aEditorColors[i, 2], this.cVFPOptPath, HKEY_CURRENT_USER, .t.) 
		endfor		
		
		return .T.
		
	endproc  	

	procedure addInArray
		lparameters cEntry, cRegValue

		local nIndex
		nIndex = ascan(this.aEditorColors, cEntry, 1, -1, 1, 15)
		
		if nIndex = 0 
			if empty(this.aEditorColors)
				this.aEditorColors[1, 1] = cEntry
				nIndex = 1
			else
				nIndex = alen(this.aEditorColors, 1) + 1
				dimension this.aEditorColors[nIndex, 2]
				this.aEditorColors[nIndex, 1] = cEntry
			endif 	
		endif 
		
		this.aEditorColors[nIndex, 2] = cRegValue
		
	endproc

	procedure getTheme
		lparameters cFileTheme
		
		local cTheme
		cTheme = ""
		cFileTheme = addbs(this.cPathTheme) + forceext(cFileTheme, "json")
		if file(cFileTheme)
			cTheme = chrtran(filetostr(cFileTheme), "/$", "")
		endif 	

		return cTheme
	endproc 

	Function SetScreenColors
		Local cEditorVariableColor, cForeColor, cBackColor, cRegKey
		local oRegApi 

		oRegApi = Newobject("Registry",home() + "FFC\Registry.VCX")

		oRegApi.getregkey("EditorVariableColor", @cEditorVariableColor, this.cVFPOptPath, HKEY_CURRENT_USER)

		cForeColor = Substr(cEditorVariableColor, 5, At(",", cEditorVariableColor, 3) - 5)
		cBackColor = Substr(cEditorVariableColor, At(",", cEditorVariableColor, 3) + 1, At(")", cEditorVariableColor, 1) - At(",", cEditorVariableColor, 3) - 1)

		_screen.ForeColor = Rgb(&cForeColor)
		_screen.BackColor = Rgb(&cBackColor)

	Endfunc	
	
enddefine