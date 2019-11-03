clear

oColor = createobject("Color")
?oColor.Hex2Rgb2Register("")

define class color as custom

	procedure Hex2Rgb2Register
		lparameters cHexForeColor, cHexBackColor
		
		local i, nPos, cReturn, cValue
		
		if empty(cHexForeColor)
			cHexForeColor = "#000000"
		endif 
		
		if empty(cHexBackColor)
			cHexBackColor = "#ffffff"
		endif 		

		cHexForeColor = substr(cHexForeColor, 1, 7)
		cHexBackColor = substr(cHexBackColor, 1, 7)

		do case
			case substr(cHexForeColor, 1, 1) != [#] or substr(cHexBackColor, 1, 1) != [#]
				return "error"

			case len(cHexForeColor) != 7 or len(cHexBackColor) != 7
				return "error"

			otherwise

				cReturn = [RGB(]
				nPos = 2
				for i = 1 to 3
					cValue = this.Hex2Dec(substr(cHexForeColor, nPos, 2))
					cReturn = cReturn + cValue + [,]
					nPos = nPos + 2
				next
				
				nPos = 2
				for i = 1 to 3
					cValue = this.Hex2Dec(substr(cHexBackColor, nPos, 2))
				
					if i # 3
						cReturn = cReturn + cValue + [,]
					else
						cReturn = cReturn + cValue + [)]
					endif
					nPos = nPos + 2
				next		
		endcase

		return cReturn + ", NoAuto, NoAuto"
	endproc

	procedure Hex2Dec
		lparameters cHexString
		local i, cChar, nLen, nSum, nPos

		nLen = len(cHexString)
		nSum = 0
		nPos = 0
		for i = 1 to nLen
			cChar = substr(cHexString, nLen - nPos, 1)
			do case
				case upper(cChar) = [A]
					cChar = [10]
				case upper(cChar) = "B"
					cChar = [11]
				case upper(cChar) = [C]
					cChar = [12]
				case upper(cChar) = [D]
					cChar = [13]
				case upper(cChar) = [E]
					cChar = [14]
				case upper(cChar) = [F]
					cChar = [15]
			endcase
			nSum = nSum + val(upper(cChar)) * 16 ^ (i - 1)
			nPos = nPos + 1
		next

		return transform(nSum)

	endproc

enddefine