Progr           segment
                assume  cs:Progr, ds:dane, ss:stosik

start:          mov     ax,dane
                mov     ds,ax
                mov     ax,stosik
                mov     ss,ax
                mov     sp,offset szczyt

                mov ax,7000H
                mov es,ax
                mov al,' '          ;domyslna spacja jako znak, czyt '+'
                mov es:[0],al
                mov al,0
                mov es:[1],al       ;czyszczenie pamieci
		mov es:[2],al
		mov es:[3],al	             
		mov es:[10],al
		mov es:[11],al

;///////////////// END OF ust. poczatkowe /////////////

                mov ax,0b800h
                mov es,ax       ;ustawienie początku dodatkowego segmentu na 0b800h
                mov di,0        ;ustawienie wartosci przemieszczenia (offset)
                mov cx,24       ;24 wiersze ekranu
                mov al," "      ;znak do al
cls1:           push cx         ;odlozenie 2 bajtów na stos
                mov cx,80
cls2:           mov es:[di],al  ;wsadzenie znaku do sumy adresu logicznego (ES) oraz adresu efektywnego (DI), czyli adresu fizycznego
                add di,2        ;offset +2 dla kolejnego miejsca na ekranie
                loop cls2
                pop cx
                loop cls1       ;skok jesli cx != 0, cx--

;////////////////// END Of czyszczenie ekranu //////////////


                mov ax,7000h    ;wolna pamiec
                mov es,ax

		mov dx, offset txtpodajliczbe
		mov ah, 9
		int 21h

                mov ah,01h       ;wpisz znak
                int 21h

                cmp al,'-'       ;spr czy ujemna czy dodatnia
                jnz dodatnia	 ; jesli znak = '-' to wpisanie '-' w pole znaku i przejscie do podania 3 kolejnych cyfr, jesli nie, to skok
                mov di,0         ;zapis do 70000H minusa
                mov es:[di],al
                mov al,0
                jmp input3cyfry

input3cyfry:
                mov ah,01h           ;dodatkowy input 1 cyfry jesli 1 znak byl '-'
				     ;70000H - znak
                int 21h              ;70001H - setki
                                     ;70002H - dzies
dodatnia:                            ;70003H - jedn     
		sub al,48
                call isanumber		;spr czy znak to cyfra
                mov di,1
                mov es:[di],al
                mov ah,01h
                int 21h
                sub al,48d
		call isanumber
                mov di,2
                mov es:[di],al
                mov ah,01h
                int 21h
                sub al,48d
		call isanumber
                mov di,3
                mov es:[di],al

 ;////////////////////// END OF INPUT //////////////////////
                call endofline
                mov dx, offset txtpodanaliczba
                mov ah, 9
                int 21h
                mov di,0
                call wyswietlinput
 ;////////////////////// END OF Pokazanie inputu ////////////	

		mov di,1
		mov ax,0
		mov bx,0
		mov dh,0
		mov dl,10
		mov ax,0
		mov al,es:[di]		; bierz 1
		mul dl			; 10
		mov bx,ax		; 0+10 = 10
		inc di
		mov ax,0
		mov al,es:[di]		; bierz 2
		add ax,bx		; 10+2 = 12
		mul dl			; 120
		mov bx,ax
		mov ax,0
		inc di
		mov al,es:[di]		; bierz 3
		add bx,ax		; 120+3=123



		mov di,10
		mov es:[di],bl



	
 ;/////////////////////// END OF cyfry do liczby /////////// /////////////////////////////////////////////////////////////////////////////

		push ax
		push bx
		push cx
		push dx
		push di

		mov di,0
		mov cl,es:[di]
		cmp cl,'-'		;jesli ujemna, to wartosc max dla ujemnej to 128, a dla dodatniej 127
		je ujemnatester
		cmp bl,127
		jna tester1
		jmp nexttester
ujemnatester:	cmp bl,128
		jna tester1
nexttester:	call endofline
                mov dx, offset txtzlyzakres  ;///////////////////// if true go to end -> zly zakres [-128 ; 127]
                mov ah, 9
                int 21h
		pop di
		pop dx
		pop cx		;wyjecie stosu przed zakonczeniem programu
		pop bx
		pop ax
		mov     ah,4ch		;kooniec programu
                mov         al,0
                int         21h	

tester1:	pop di
		pop dx
		pop cx
		pop bx
		pop ax

 ;/////////////////////// END OF is -128 < x < 127 /////////////

		mov bl,0
		mov al, es:[0]
		cmp al,'-'		; input = 5, jesli znak to '-' to zrobienie z 5 -> -5 i do 70011H
		jnz dodatniahex		; 0 - 5 = -5
		mov al, es:[10]		
		sub bl,al
		mov es:[11],bl

dodatniahex:

 ;/////////////////////// end of Przepelnienie hex ///////////
                ;to hex

		call endofline
                mov dx, offset txthex
                mov ah, 9
                int 21h
	
		mov ax,0
		mov bx,0
		mov cx,0
		mov dx,0
		
		       
		mov di, 10
		call ifminusincdi
        	mov bl, es:[di]         ;125 = 7D
        	and bl, 0Fh      	;0D
        	mov al, es:[di]         ;125
        	and al, 0F0h      	;70
        	mov cl, 04d      	;ilosc powtorzen nastepnej komendy		
        	ror al, cl      	;rotate right x4 bo cl=4, al = 07
		mov dl,al		; do dl, bo dl jest wyswietlane przez przerwanie
        	call toascii         ; + 48 bo cyfry w ascii
        	mov ah,02h
       		int 21h
		mov dl,bl
        	call toascii           ; + 48 bo cyfry w ascii
       		mov ah,02h
        	int 21h

; /////////////////////////// END OF hex ///////////////////////	

		call endofline
                mov dx, offset txtzm
                mov ah, 9
                int 21h

		mov al, es:[0]
		cmp al,'-'
		jnz minuszm
		mov dl,'1'
        	mov ah,02h
        	int 21h
		jmp kropka	;1. / 0. w ZM w zaleznosci od znaku
minuszm:	mov dl,'0'
		mov ah,02h
		int 21h
kropka:		mov dl,'.'
        	mov ah,02h
        	int 21h

;////////// start binarka ///////


		mov al,es:[10]
		cmp al,128
		jne continuetozm
		mov dx, offset txtminus128
                mov ah, 9
                int 21h
		call endofline
		mov dx, offset txtzu2
                mov ah, 9
                int 21h
		mov dx, offset txtminus128zu2
                mov ah, 9
                int 21h
		mov     ah,4ch
                mov         al,0
                int         21h

continuetozm:	mov cx, 8 
		mov dx, 0 
		mov di,10
		mov ax,es:[di]
		call binaryanddisplay

; ///////////////////////////// END OF ZM ////////////////////////

		call endofline
                mov dx, offset txtzu2
                mov ah, 9
                int 21h
		
		mov ax,es:[0]
		cmp al,'-'
		jne zu2likezm
    		mov cx, 8 
		mov dx, 0 
		mov di,10
		mov ax,es:[di]
		mov ah,0
		not al
		add al,00000001B
		call binaryanddisplay
		jmp ending
zu2likezm:    	 
		mov dx, 0 
		mov di,10
		mov ax,es:[di]
		call binaryanddisplay	

; ///////////////////////////// END OF ZU2 ////////////////////

ending:
                mov     ah,4ch
                mov         al,0
                int         21h



binaryanddisplay:		;dzieli przez 2 (by miec reszte = binarke)
		call comparator
binary1: 	mov bx, 2  
    		div bx  
    		push dx		;reszta z dzielenia
		xor dx, dx	;'szybsze' zerowanie rejestru za pomoca XOR'a
		jmp binary2
fillzerobin:	mov dx,0
	    	push dx 
binary2:     	loop binary1
		mov bx,0
		call comparator
wyswietlbin2:	cmp cx, 0 	
		je endbin	
		pop dx 
    		add dx,48 
   		mov ah, 02h
		int 21h 
		dec cx 
        	jmp wyswietlbin2 
endbin:		ret


comparator:	push ax		;ustawia ilosc znakow pokazywanych w wyswietlaniu ZM i ZU2
		mov ax,es:[10]	
		cmp al,127
		mov cx,9
		jg endcomparator	;greater - skok, jeśli większe (ze znakiem), w tym ze rejestru znaku nie uzywamy w zasadzie
		cmp al,63
		mov cx,8
		jg endcomparator
		cmp al,31
		mov cx,7
		jg endcomparator
		cmp al,15
		mov cx,6
		jg endcomparator
		cmp al,7
		mov cx,5
		jg endcomparator
		cmp al,3
		mov cx,4
		jg endcomparator
		cmp al,1
		mov cx,3
		jg endcomparator
		mov cx,2
endcomparator:	pop ax
		ret


isanumber:	cmp al,0
		jb notanumber	;below - skok, jeśli mniejsze (bez znaku)
		cmp al,9
		ja notanumber	;above - skok, jeśli większe (bez znaku)
		ret
notanumber:	call endofline
		mov dx, offset txtnotanumber
                mov ah, 9
                int 21h
		jmp ending


wyswietlinput:  push cx
                push di
                mov cx,3
                ;mov di,0
                mov dl,es:[di]     ; bez + 48 bo symbol jest "w symbolu"
                mov ah,02h
                int 21h
wyswietlinputloop: inc di          ; przed wywolaniem pierwszym, wyzerowac di
                mov dl,es:[di]
                add dl,48          ; + 48 bo cyfry w ascii
                mov ah,02h
                int 21h
                loop wyswietlinputloop
                pop di
                pop cx
                ret


toascii:	cmp dl,9
		jng cyfrahex
		add dl,7	; rooznica pomiedzy literami a cyframi w ascii
cyfrahex:	add dl,48
		ret


endofline:      mov dx, offset txtendofline
                mov ah, 9
                int 21h
                ret


ifminusincdi:	push ax
		mov al, es:[0]
		cmp al,'-'
		jnz ifminusincdi0
		inc di
ifminusincdi0:	pop ax
		ret





Progr           ends

dane            segment

                txtpodajliczbe db "Podaj liczbe [-128 : 127]: $"
                txtpodanaliczba db "Podana liczba:      $"
		txthex db "Podana liczba w HEX: $"
		txtzm db "Podana liczba w ZM:  $"
		true db "/// TRUE ///$"
		false db "/// False /// $"
		txtminus128 db "010000000$"
		txtminus128zu2 db "110000000$"
		txtzu2 db "Podana liczba w ZU2:   $"
		txtnotanumber db "Nie podano dozwolonego znaku ['-', [0-9]].$"
                txtendofline db "",13,10,"$"
		txtzlyzakres db "Blad. Liczba nie jest z zakresu [-128 : 127].$"


dane            ends

stosik          segment
                dw    100h dup(0)
szczyt          Label word
stosik          ends

end start