#INCLUDE "PROTHEUS.CH"

//Array contendo tradução
Static aTranslate := {}

#DEFINE __VERSION "v1.0"

//---------------------------------------------------------------------
/*/{Protheus.doc} Translate
Rotina didática para traduzir textos.
O seu funcionamento dependerá da página do Google Translate
Testado no dia 23/03/2012


en|de | Inglês para Alemão
en|es | Inglês para Espanhol
en|fr | Inglês para Francês
en|it | Inglês para Italiano
en|pt | Inglês para Português
de|en | Alemão para Inglês
de|fr | Alemão para Francês
es|en | Espanhol para Inglês
fr|en | Francês para Inglês
fr|de | Francês para Alemão
it|en | Italiano para Inglês
pt|en | Português para Inglês
Etc...

@author Vitor Emanuel Batista
@since 18/01/2012
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
User Function Translate()
	Local oDlg
	Local cText := Space(100)
	Local cResult := ""
	Local aLang := {'pt|en=Português x Inglês','en|pt=Ingles x Portugês','pt|es=Português x Espanhol','es|pt=Espanhol x Português','es|en=Espanhol x Inglês'}
	Local cLang := aLang[1]
	
	Local oFont := TFont():New('Courier new',,-18,.T.,.T.)
	
	DEFINE MSDIALOG oDlg TITLE __VERSION+' Tradutor de textos utilizando Google Translate' FROM 0,0 TO 225,600 PIXEL
		
		@ 05,05 Say "Tradutor" OF oDlg Font oFont Color 3754973 Pixel
		
		//Combobox contendo traduções possíveis
		@ 05,150 Combobox oLang Var cLang Items aLang Size 75,50 Of oDlg Pixel	
		
		//Botão com CSS para apresentar a tradução no MultiLine da esquerda
		@ 03, 230 Button oTranslate Prompt "Traduzir" Action Translate(cLang,cText,@cResult) Size 40,16 Pixel  
		oTranslate:SetCss("QPushButton{ border-radius: 3px;border: 1px solid #4D90FE; color: #FFFFFF; background-color: #3079ED;  }")
		
		//Linha para dividir
		@ 20,0 To 21.5,300 Of oDlg COLOR CLR_BLACK,CLR_BLACK DESIGN pixel
		
		//Multiline para escrever texto a ser traduzido
		@ 30 , 005 Get oText Var cText MultiLine Size 140,80 Pixel
		
		//Multiline com a tradução do texto
		@ 30 , 152 Get cResult MultiLine Size 140,80 NO MODIFY COLOR CLR_BLACK,CLR_BLUE Pixel

	ACTIVATE MSDIALOG oDlg CENTERED

Return 

//---------------------------------------------------------------------
/*/{Protheus.doc} Translate
Converte HTML do HTTPGET para a tradução da lingua escolhida 

@param cLang Lingua escolhida
@param cTexto Texto para tradução
@author Vitor Emanuel Batista
@since 18/01/2012
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Static Function Translate(cLang,cText,cResult)
	Local nTranslate
	Local cTranslate := ""
	Local cLink, cHtml
	
	// Transforma espaços em branco para URL Encoding
	cText := StrTran(cText," ","%20")
	
	// Transforma ENTER para URL Encoding
	cText := StrTran(cText,CRLF,"%0A")
	
	// Link do Google para traduzir texto na lingua escolhida 
	cLink := "http://translate.google.com/translate_t?text="+AllTrim(cText)+"&langpair="+AllTrim(cLang)

	// Emula um client HTTP, retornando página HTML	
	cHtml := HTTPGET(cLink)
	
	If ValType(cHtml) <> "C"
		cResult := ""
		Alert("ERRO NA REQUISIÇÃO AO SERVIDOR GOOGLE")
		Return 	
	EndIf
   
	ConvertHtml(cHtml)

	// Processa array contendo a tradução
	For nTranslate := 1 To Len(aTranslate)
		cTranslate += aTranslate[nTranslate] + CRLF
	Next nTranslate

	// Limpa array de tradução para uma próxima utilização
	aTranslate := {}

	cResult := cTranslate 
Return 

//---------------------------------------------------------------------
/*/{Protheus.doc} ConvertHtml
Converte HTML do HTTPGET para a tradução da lingua escolhida 

@author Vitor Emanuel Batista
@since 18/01/2012
@version MP10
@return Nil
/*/
//---------------------------------------------------------------------
Static Function ConvertHtml(cHtml)
	Local nAt
	
	nAt := At("result_box",cHtml)
	cHtml := SubStr(cHtml,nAt)
	nAt := At(">",cHtml)+1
	cHtml := SubStr(cHtml,nAt)
	nAt := At(">",cHtml)+1
	cHtml := SubStr(cHtml,nAt)
	nAt := At("<",cHtml)-1
	
	// Adiciona linha de tradução na array
	aAdd(aTranslate,SubStr(cHtml,1,nAt))
	
	// Verifica se há mais linhas de tradução
	If SubStr(cHtml,nAt+1,4) == "<br>"		
		ConvertHtml(SubStr(cHtml,nAt+5))
	EndIf
	
Return