[org 0x0100]
jmp start

gameTitle: db 'Atari Breakout Arcade Game'
gameTitleLen: dw 26
escapeKeyMessage: db 'press esc to exit'
escapeKeyMessagelen: dw 17
escapeMessage: db 'Thanks for Playing!!!'
escapeMessageLen: dw 21
prompt: db 'press enter to continue'
promptLen: dw 23
gameMenu: db 'Game Menu'
gameMenuLen: dw 9
opt1: db 'press 1 to play the game'
opt1len: dw 24
opt2: db 'press 2 to view the rules'
opt2Len: dw 25
gameRules: db 'Rules of the game'
gameRulesLen: dw 17
lifeMessage: db 'you start with 3 lives and you lose when lives reaches 0'
lifeMessageLen: dw 56
movementMessage:db 'use A to move the paddle left and D to move the paddle right'
movementMessageLen: dw 60
scoreDisplay: db 'SCORE'
scoreDisplayLen: dw 5
lifeDisplay: db 'LIFE'
lifeDisplayLen: dw 4
rulesPrompt: db 'Press any key to start playing...'
rulesPromptLen: dw 33
restartMessage: db 'Press R to Restart or Esc to Exit'
restartMessageLen: dw 33
pauseLine1: db 'GAME PAUSED'
pauseLine1Len: dw 11
pauseLine2: db 'DO YOU WISH TO CONTINUE? (Y/N)'
pauseLine2Len: dw 30
pauseErase: db '                                        ' ; Space buffer to erase
finalScoreText: db 'Final Score: '
finalScoreTextLen: dw 13
gameOver1: db 'GAME OVER'
gameOverLen: dw 9 
gameOverMessage: db 'Better luck next time!!'
gameOverMessageLen: dw 23 
gameWin1: db 'You Win!!!'
gameWinLen: dw 9 
gameWinMessage: db 'Congratulations!!!'
gameWinMessageLen: dw 18
clearColX: dw 1
clearRowY: dw 4
ballClearColX: dw 1
ballClearRowY: dw 4
tempBallColX: dw 1
tempBallRowY: dw 4
ballErase: db ' '
ball: db '*'
ballColX: dw 25
ballRowY: dw 22
ballLen: dw 1
ballDirColX: dw 0
ballDirRowY: dw -1
paddleErase: db ' '     
paddle: db '<======>'
paddleLen: dw 8
paddleColX: dw 22
paddleRowY: dw 23
clearBrickColX: dw 1
clearBrickRowY: dw 4 
brickErase: db ' '
score: dw 0
lives: dw 3
tick_count: dw 0        
old_isr: dd 0  

loseLifeSound:
    push ax
    push bx
    push cx
    
    in al, 0x61
    or al, 0x03
    out 0x61, al
    
    mov al, 0xB6
    out 0x43, al
    mov ax, 4000
    out 0x42, al
    mov al, ah
    out 0x42, al
    
    mov cx, 2000
.wait3:
    loop .wait3
    
    in al, 0x61
    and al, 0xFC
    out 0x61, al
    
    pop cx
    pop bx
    pop ax
    ret

playBrickSound:
    push ax
    push bx
    push cx
    
    in al, 0x61
    or al, 0x03
    out 0x61, al
    
    mov al, 0xB6
    out 0x43, al
    mov ax, 143
    out 0x42, al
    mov al, ah
    out 0x42, al
    
    mov cx, 150
.wait1:
    loop .wait1
    
    in al, 0x61
    and al, 0xFC
    out 0x61, al
    
    pop cx
    pop bx
    pop ax
    ret

playPaddleSound:
    push ax
    push bx
    push cx
    
    in al, 0x61
    or al, 0x03
    out 0x61, al
    
    mov al, 0xB6
    out 0x43, al
    mov ax, 700
    out 0x42, al
    mov al, ah
    out 0x42, al
    
    mov cx, 300
.wait2:
    loop .wait2
    
    in al, 0x61
    and al, 0xFC
    out 0x61, al
    
    pop cx
    pop bx
    pop ax
    ret

timer_isr:
    push ax
    inc word [cs:tick_count] 
    mov al, 0x20
    out 0x20, al             
    pop ax
    iret                     

hook_timer:
    push ax
    push es
    cli                     
    xor ax, ax
    mov es, ax              
    mov ax, [es:0x08*4]
    mov [old_isr], ax
    mov ax, [es:0x08*4+2]
    mov [old_isr+2], ax
    mov word [es:0x08*4], timer_isr
    mov [es:0x08*4+2], cs
    sti                     
    pop es
    pop ax
    ret

unhook_timer:
    push ax
    push es
    cli
    xor ax, ax
    mov es, ax
    mov ax, [old_isr]
    mov [es:0x08*4], ax
    mov ax, [old_isr+2]
    mov [es:0x08*4+2], ax
    sti
    pop es
    pop ax
    ret

resetGameVars:
    mov word [score], 0
    mov word [lives], 3
    mov word [ballColX], 25
    mov word [ballRowY], 22
    mov word [ballDirColX], 0
    mov word [ballDirRowY], -1
    mov word [paddleColX], 22
    mov word [paddleRowY], 23
    ret

printGameWinScr:
	call WelcomeScr
	call gameWinDisplay
	call gameWinMessageDisplay
    call printFinalScore      
	call printRestartMessage 
	ret

printGameOverScr:
	call WelcomeScr
	call gameOverDisplay
	call gameOverMessageDisplay
    call printFinalScore      
	call printRestartMessage 
	ret
	
printFinalScore:
    mov ax, 30
    push ax
    mov ax, 14
    push ax
    mov ax, 0x0F 
    push ax
    mov ax, finalScoreText
    push ax
    push word [finalScoreTextLen]
    call printStr
    ; Offset calculation: (14 * 80 + 30 + 13) * 2 = 2486 (approx)
    mov ax, [score]
    push ax
    call printNumFinal
    ret

printNumFinal:
    push bp
	mov bp, sp
	push es
	push ax
	push bx
	push cx
	push dx
	push di
	mov ax, 0xb800
	mov es, ax 
	mov ax, [bp+4] 
	mov bx, 10 
	mov cx, 0 
nextdigitF: 
	mov dx, 0 
	div bx 
	add dl, 0x30 
	push dx 
	inc cx 
	cmp ax, 0 
	jnz nextdigitF 
	mov di, 2330 ; Location for final score number (Row 14, ~Col 45)
nextposF: 
	pop dx 
	mov dh, 0x0F 
	mov [es:di], dx 
	add di, 2 
	loop nextposF 
	pop di
	pop dx
	pop cx
	pop bx
	pop ax
	pop es
	pop bp
	ret 2

printRestartMessage:
	mov ax, 30
	push ax 
	mov ax, 16
	push ax 
	mov ax, 0x8E 
	push ax 
	mov ax, restartMessage
	push ax 
	push word [restartMessageLen]
    call printStr
	ret
	
gameWinMessageDisplay:
	mov ax, 29
	push ax 
	mov ax, 13
	push ax 
	mov ax, 0x0E 
	push ax 
	mov ax, gameWinMessage
	push ax 
	push word [gameWinMessageLen]
    call printStr
	ret

gameWinDisplay:
	mov ax, 35
	push ax 
	mov ax, 11
	push ax 
	mov ax, 0x0E 
	push ax 
	mov ax, gameWin1
	push ax 
	push word [gameWinLen]
    call printStr
	ret

gameOverMessageDisplay:
	mov ax, 29
	push ax 
	mov ax, 13
	push ax 
	mov ax, 0x0E 
	push ax 
	mov ax, gameOverMessage
	push ax 
	push word [gameOverMessageLen]
    call printStr
	ret

gameOverDisplay:
	mov ax, 35
	push ax 
	mov ax, 11
	push ax 
	mov ax, 0x0E 
	push ax 
	mov ax, gameOver1
	push ax 
	push word [gameOverLen]
    call printStr
	ret

rightCompartmentDivider:
    push bp
    mov bp, sp
    push es
    push ax
    push di
    mov ax, 0xb800
    mov es, ax
    mov di, 2026       
rightCompartmentDividerLoop:
    mov word [es:di], 0x7F20   
    add di, 2
    cmp di, 2078
    jle rightCompartmentDividerLoop
    pop di
    pop ax
    pop es
    pop bp
    ret

gameRedBrickRow:
    push bp
    mov bp, sp
    push es
    push ax
    push di
    mov ax, 0xb800
    mov es, ax
    mov di, 162       
redBrickLoop:
    mov word [es:di], 0x4F20   
    add di, 2
    cmp di, 264
    jle redBrickLoop
    pop di
    pop ax
    pop es
    pop bp
    ret

gameYellowBrickRow:
    push bp
    mov bp, sp
    push es
    push ax
    push di
    mov ax, 0xb800
    mov es, ax
    mov di, 322      
yellowBrickLoop:
    mov word [es:di], 0x6EDB   
    add di, 2
    cmp di, 424
    jle yellowBrickLoop
    pop di
    pop ax
    pop es
    pop bp
    ret

gameGreenBrickRow:
    push bp
    mov bp, sp
    push es
    push ax
    push di
    mov ax, 0xb800
    mov es, ax
    mov di, 482      
greenBrickLoop:
    mov word [es:di], 0x22DB   
    add di, 2
    cmp di, 584
    jle greenBrickLoop
    pop di
    pop ax
    pop es
    pop bp
    ret

updateBallPosition:
    mov ax,[ballColX]
	mov [ballClearColX],ax
    add ax,[ballDirColX]
    mov [tempBallColX],ax
    mov ax,[ballRowY]
	mov [ballClearRowY],ax
    add ax,[ballDirRowY]
    mov [tempBallRowY],ax
    call getAttribute
    call collision
    ret

collision:
    cmp cl,0x07          
    je skipCollision
    cmp cl,0x00          
    je skipCollision
    cmp cl,0x2F          
    je near leftWall
    cmp cl,0x7F          
    je near rightWall
    cmp cl,0x0F          
    je near bottomWall
    cmp cl,0xEE          
    je near topWall
    cmp cl,0x05          
    je near leftPaddle
    cmp cl,0x0B          
    je near middlePaddle
    cmp cl,0x0C          
    je near rightPaddle
    cmp cl,0x22          
    je greenBrick
    cmp cl,0x6E          
    je yellowBrick
    cmp cl,0x4F          
    je redBrick
skipCollision:
	mov ax,[ballColX]
    add ax,[ballDirColX]
    mov [ballColX],ax
    mov ax,[ballRowY]
    add ax,[ballDirRowY]
    mov [ballRowY],ax
    ret
greenBrick:
	call playBrickSound
    mov ax,[ballDirRowY]
    neg ax
    mov [ballDirRowY],ax
	mov ax,[tempBallColX]
	mov [clearBrickColX],ax
	mov ax,[tempBallRowY]
	mov [clearBrickRowY],ax
	call eraseBrick
	mov ax,[score]
	add ax,10
	mov [score],ax
    jmp skipCollision
yellowBrick:
	call playBrickSound
    mov ax,[ballDirRowY]
    neg ax
    mov [ballDirRowY],ax
	mov ax,[tempBallColX]
	mov [clearBrickColX],ax
	mov ax,[tempBallRowY]
	mov [clearBrickRowY],ax
	call eraseBrick
	mov ax,[score]
	add ax,20
	mov [score],ax
    jmp skipCollision
redBrick:
	call playBrickSound
    mov ax,[ballDirRowY]
    neg ax
    mov [ballDirRowY],ax
	mov ax,[tempBallColX]
	mov [clearBrickColX],ax
	mov ax,[tempBallRowY]
	mov [clearBrickRowY],ax
	call eraseBrick
	mov ax,[score]
	add ax,30
	mov [score],ax
    jmp skipCollision
leftPaddle:
    mov ax,-1
    mov [ballDirColX],ax
    mov ax,-1
    mov [ballDirRowY],ax
    dec word [ballRowY] 
    jmp skipCollision
middlePaddle:
    mov ax,[ballDirRowY]
    neg ax
    mov [ballDirRowY],ax
    dec word [ballRowY]
    jmp skipCollision
rightPaddle:
    mov ax,1
    mov [ballDirColX],ax
    mov ax,-1
    mov [ballDirRowY],ax
    dec word [ballRowY]
    jmp skipCollision
leftWall:
    mov ax,1
    mov [ballDirColX],ax
    jmp skipCollision
rightWall:
    mov ax,-1
    mov [ballDirColX],ax
    jmp skipCollision
topWall:
    mov ax,1
    mov [ballDirRowY],ax
    jmp skipCollision
bottomWall:
	call loseLifeSound
    mov ax,[lives]
	dec ax
	mov [lives],ax
	mov ax,0
	mov [ballDirColX],ax
	mov ax,-1
	mov [ballDirRowY],ax
	mov ax,25
	mov [ballColX],ax
	mov ax,22
	mov [ballRowY],ax
    jmp skipCollision

getAttribute:
    push bp
    mov bp, sp
    push es
    push di
    push ax
    push bx
    push dx
    mov ax,0B800h
    mov es,ax
    mov ax,[tempBallRowY]
    mov bx,80
    mul bx
    add ax,[tempBallColX]
    shl ax,1
    mov di,ax
    mov cl,[es:di+1]    
    pop dx
    pop bx
    pop ax
    pop di
    pop es
    pop bp
    ret

printBall:
	mov ax, [ballColX]
	push ax 
	mov ax, [ballRowY]
	push ax 
	mov ax, 0x0E 
	push ax 
	mov ax, ball
	push ax 
	push word [ballLen]
    call printStr
	ret

movePaddle:
    cmp ah,0x1E    ; 'A'
    je left
    cmp ah,0x20    ; 'D'
    je right
    ret
left:
    mov ax,[paddleColX]
    cmp ax,2       
    jle done1
    
    mov bx, [paddleColX]
    add bx, 7
    mov [clearColX], bx
    mov bx, [paddleRowY]
    mov [clearRowY], bx
    call erase
    
    mov bx, [paddleColX]
    add bx, 6
    mov [clearColX], bx
    mov bx, [paddleRowY]
    mov [clearRowY], bx
    call erase
    
    mov ax,[paddleColX]
    sub ax, 2
    mov [paddleColX],ax
    jmp done1
right:
    mov ax,[paddleColX]
    cmp ax,44      
    jge done1
    
    mov bx, [paddleColX]
    mov [clearColX], bx
    mov bx, [paddleRowY]
    mov [clearRowY], bx
    call erase
    
    mov bx, [paddleColX]
    inc bx
    mov [clearColX], bx
    mov bx, [paddleRowY]
    mov [clearRowY], bx
    call erase
    
    mov ax,[paddleColX]
    add ax, 2
    mov [paddleColX],ax
done1:
    ret
	
printPaddle:
    push ax
    push bx
    push cx
    push di
    push si
    push es

    mov ax, 0B800h
    mov es, ax            
    mov ax, [paddleRowY]
    mov bx, 80
    mul bx
    add ax, [paddleColX]
    shl ax, 1
    mov di, ax
    mov si, paddle        
    mov cx, 3
drawLeft:
    lodsb                 
    mov ah, 05h           
    stosw
    loop drawLeft
    mov cx, 2
drawMiddle:
    lodsb
    mov ah, 0Bh           
    stosw
    loop drawMiddle
    mov cx, 3
drawRight:
    lodsb
    mov ah, 0Ch           
    stosw
    loop drawRight

    pop es
    pop si
    pop di
    pop cx
    pop bx
    pop ax
    ret
	
printLife:
	mov ax,[lives]
	push ax
    call printNumLife
	ret
	
printNumLife: 
	push bp
	mov bp, sp
	push es
	push ax
	push bx
	push cx
	push dx
	push di
	mov ax, 0xb800
	mov es, ax 
	mov ax, [bp+4] 
	mov bx, 10 
	mov cx, 0 
nextdigit1: 
	mov dx, 0 
	div bx 
	add dl, 0x30 
	push dx 
	inc cx 
	cmp ax, 0 
	jnz nextdigit1 
	mov di, 3006
nextpos1: 
	pop dx 
	mov dh, 0x0E 
	mov [es:di], dx 
	add di, 2 
	loop nextpos1 
	pop di
	pop dx
	pop cx
	pop bx
	pop ax
	pop es
	pop bp
	ret 2

printLifeDisplay:
	mov ax, 56
	push ax 
	mov ax, 18
	push ax 
	mov ax, 0x0E 
	push ax 
	mov ax, lifeDisplay
	push ax 
	push word [lifeDisplayLen]
    call printStr
	ret

printScoreDisplay:
	mov ax, 56
	push ax 
	mov ax, 6
	push ax 
	mov ax, 0x0E 
	push ax 
	mov ax, scoreDisplay
	push ax 
	push word [scoreDisplayLen]
    call printStr
	ret

printMovementMessage:
	mov ax, 8
	push ax 
	mov ax, 12
	push ax 
	mov ax, 0x0E 
	push ax 
	mov ax, movementMessage
	push ax 
	push word [movementMessageLen]
    call printStr
	ret

printLifeMessage:
	mov ax, 9
	push ax 
	mov ax, 10
	push ax 
	mov ax, 0x0E 
	push ax 
	mov ax, lifeMessage
	push ax 
	push word [lifeMessageLen]
    call printStr
	ret

printGameRulesMessages:
	mov ax, 31
	push ax 
	mov ax, 8
	push ax 
	mov ax, 0x0E 
	push ax 
	mov ax, gameRules
	push ax 
	push word [gameRulesLen]
    call printStr
	ret

printRulesPrompt:
    mov ax, 22
	push ax 
	mov ax, 18
	push ax 
	mov ax, 0x8E
	push ax 
	mov ax, rulesPrompt
	push ax 
	push word [rulesPromptLen]
    call printStr
	ret

printOption2:
	mov ax, 26
	push ax 
	mov ax, 13
	push ax 
	mov ax, 0x0E 
	push ax 
	mov ax, opt2
	push ax 
	push word [opt2Len]
    call printStr
	ret

printOption1:
	mov ax, 26
	push ax 
	mov ax, 11
	push ax 
	mov ax, 0x0E 
	push ax 
	mov ax, opt1
	push ax 
	push word [opt1len]
    call printStr
	ret

printMenu:
	mov ax, 28
	push ax 
	mov ax, 7
	push ax 
	mov ax, 0x0E 
	push ax 
	mov ax, gameMenu
	push ax 
	push word [gameMenuLen]
    call printStr
	ret

printScore:
	mov ax,[score]
	push ax
    call printNumScore
	ret
	
printNumScore: 
	push bp
	mov bp, sp
	push es
	push ax
	push bx
	push cx
	push dx
	push di
	mov ax, 0xb800
	mov es, ax 
	mov ax, [bp+4] 
	mov bx, 10 
	mov cx, 0 
nextdigit: 
	mov dx, 0 
	div bx 
	add dl, 0x30 
	push dx 
	inc cx 
	cmp ax, 0 
	jnz nextdigit 
	mov di, 1086
nextpos: 
	pop dx 
	mov dh, 0x0E 
	mov [es:di], dx 
	add di, 2 
	loop nextpos 
	pop di
	pop dx
	pop cx
	pop bx
	pop ax
	pop es
	pop bp
	ret 2
printStr:
	push bp
	mov bp,sp
	push es
	push ax
	push cx
	push si
	push di
	mov ax,0xb800
	mov es,ax
	mov al,80
	mul byte[bp+10]
	add ax,[bp+12]
	shl ax,1
	mov di,ax
	mov si,[bp+6]
	mov cx,[bp+4]
	mov ah,[bp+8]
	nextchar:
	mov al,[si]
	mov [es:di], ax
	add di,2
	add si,1
	loop nextchar
	pop di
	pop si
	pop cx
	pop ax
	pop es
	pop bp
	ret 10

clrscr:
    push bp
    mov bp,sp
    push es
    push ax
    push di
    mov ax, 0xb800 
    mov es, ax 
    mov di, 0 
nextLoc: 
    mov word [es:di], 0x0720 
    add di, 2 
    cmp di, 4000 
    jne nextLoc
    pop di
    pop ax
    pop es
    pop bp
    ret

WelcomeScr:
    push bp
    mov bp,sp
    push es
    push ax
    push di
    mov ax, 0xb800 
    mov es, ax 
    mov di, 0 
welcomeNextChar: 
    mov word [es:di], 0x0720 
    add di, 2 
    cmp di, 4000 
    jne welcomeNextChar
    pop di
    pop ax
    pop es
    pop bp
    ret

erase:
	mov ax, [clearColX]
	push ax 
	mov ax, [clearRowY]
	push ax 
	mov ax, 0x00 
	push ax 
	mov ax, paddleErase
	push ax 
	mov ax,1
	push word ax
    call printStr
	ret
	
eraseBall:
	mov ax, [ballClearColX]
	push ax 
	mov ax, [ballClearRowY]
	push ax 
	mov ax, 0x00 
	push ax 
	mov ax, ballErase
	push ax 
	mov ax,1
	push word ax
    call printStr
	ret
	
eraseBrick:
	mov ax, [clearBrickColX]
	push ax 
	mov ax, [clearBrickRowY]
	push ax 
	mov ax, 0x00 
	push ax 
	mov ax, brickErase
	push ax 
	mov ax,1
	push word ax
    call printStr
	ret

gameDividerColumn:
    push bp
    mov bp,sp
    push es
    push ax
    push di
    mov ax, 0xb800 
    mov es, ax 
    mov di, 106 
gameDividerColumnNextChar: 
    mov word [es:di], 0x7F20 
    add di, 160 
    cmp di, 3946
    jne gameDividerColumnNextChar
    pop di
    pop ax
    pop es
    pop bp
    ret

gameRightMostColumn:
    push bp
    mov bp,sp
    push es
    push ax
    push di
    mov ax, 0xb800 
    mov es, ax 
    mov di, 158 
gameRightMostColumnNextChar: 
    mov word [es:di], 0xEE20 
    add di, 160 
    cmp di, 3998 
    jne gameRightMostColumnNextChar
    pop di
    pop ax
    pop es
    pop bp
    ret

gameTopRow:
    push bp
    mov bp,sp
    push es
    push ax
    push di
    mov ax, 0xb800 
    mov es, ax 
    mov di, 0 
gameTopRowNextChar: 
    mov word [es:di], 0xEE20 
    add di, 2 
    cmp di, 160 
    jne gameTopRowNextChar
    pop di
    pop ax
    pop es
    pop bp
    ret

gameBottomRow:
    push bp
    mov bp,sp
    push es
    push ax
    push di
    mov ax, 0xb800 
    mov es, ax 
    mov di, 3840 
gameBottomRowNextChar: 
    mov word [es:di], 0x0F20 
    add di, 2 
    cmp di, 4000 
    jne gameBottomRowNextChar
    pop di
    pop ax
    pop es
    pop bp
    ret

gameLeftMostColumn:
    push bp
    mov bp,sp
    push es
    push ax
    push di
    mov ax, 0xb800 
    mov es, ax 
    mov di, 0 
gameLeftMostColumnNextChar: 
    mov word [es:di], 0x2F20 
    add di, 160 
    cmp di, 4000 
    jne gameLeftMostColumnNextChar
    pop di
    pop ax
    pop es
    pop bp
    ret

printEscapeKeyMessage:
	mov ax, 30
	push ax 
	mov ax, 16
	push ax 
	mov ax, 0x04 
	push ax 
	mov ax, escapeKeyMessage
	push ax 
	push word [escapeKeyMessagelen]
    call printStr
	ret

printEscapeMessage:
	mov ax, 30
	push ax 
	mov ax, 12
	push ax 
	mov ax, 0x0E 
	push ax 
	mov ax, escapeMessage
	push ax 
	push word [escapeMessageLen]
    call printStr
	ret

printEscapeScr:
	call WelcomeScr
	call printEscapeMessage
	ret

printGameTitle:
    mov ax, 27
	push ax 
	mov ax, 10
	push ax 
	mov ax,0x0E 
	push ax 
	mov ax, gameTitle
	push ax 
	push word [gameTitleLen]
    call printStr
    ret

	
printPrompt:
    mov ax, 28
	push ax 
	mov ax, 13
	push ax 
	mov ax, 0x8E 
	push ax 
	mov ax, prompt
	push ax 
	push word [promptLen]
    call printStr
	ret

printGameRules:
	call clrscr
	call WelcomeScr
	call printGameRulesMessages
	call printLifeMessage
	call printMovementMessage
	call printRulesPrompt 
	
	mov ah, 0
	int 16h
	
    call playGame
	ret

printGameMenu:
	call clrscr
	call WelcomeScr
	call printMenu
	call printOption1
	call printOption2
	call printEscapeKeyMessage
	ret

printWelcomeScr:
	call clrscr
	call WelcomeScr
	call printGameTitle
	call printPrompt
	call printEscapeKeyMessage
	ret
	
pressKeys:
	mov ah,0
	keyloop:
	int 0x16
	cmp ah,0x01
	je escape
	cmp ah,0x1C
	je done
	jmp keyloop
	escape:
	call printEscapeScr
	jmp finish
	done:
	ret

pressKeys1:
	keyloop1:
	mov ah,0
	int 0x16
	cmp ah,0x02
	je option1
	cmp ah,0x03
	je option2
	cmp ah,0x01
	je escape1
	jmp keyloop1
	option1:
	call playGame
	jmp done2
	option2:
	call printGameRules
	jmp done2
	escape1:
	call printEscapeScr
	jmp finish
	done2:
	ret
	
pauseGame:
    call unhook_timer      ; Stop game
    ; Center: (80-11)/2 = 34. Row 12.
    mov ax, 34
	push ax 
	mov ax, 12
	push ax 
	mov ax, 0x0F           
	push ax 
	mov ax, pauseLine1
	push ax 
	push word [pauseLine1Len]
    call printStr
    ; Center: (80-30)/2 = 25. Row 13.
    mov ax, 25
	push ax 
	mov ax, 13
	push ax 
	mov ax, 0x0F           
	push ax 
	mov ax, pauseLine2
	push ax 
	push word [pauseLine2Len]
    call printStr

pauseLoop:
    mov ah, 0
    int 16h
    cmp al, 'y'
    je resumeGame
    cmp al, 'Y'
    je resumeGame
    cmp al, 'n'
    je exitFromPause
    cmp al, 'N'
    je exitFromPause
    jmp pauseLoop

resumeGame:
    ; Erase Messages
    mov ax, 34
	push ax 
	mov ax, 12
	push ax 
	mov ax, 0x00           
	push ax 
	mov ax, pauseErase
	push ax 
	push word [pauseLine1Len]
    call printStr

    mov ax, 25
	push ax 
	mov ax, 13
	push ax 
	mov ax, 0x00           
	push ax 
	mov ax, pauseErase
	push ax 
	push word [pauseLine2Len]
    call printStr

    call hook_timer        
    mov word [tick_count], 0
    jmp mainLoop

exitFromPause:
    jmp gameOver

gameloop:
    call hook_timer
    mov word [tick_count], 0

mainLoop:
    ; SLOWED DOWN: Check for 2 ticks instead of 1
    cmp word [cs:tick_count], 2 
    jl checkInput           

    mov word [cs:tick_count], 0
    call updateBallPosition
    call eraseBall
    call printBall
    call printScore
    call printLife
    
checkInput:
    mov ah, 0x01            
    int 0x16
    jz no_key_pressed       

    mov ah, 0x00
    int 0x16
    
    cmp ah, 0x01            
    je skip_to_exit
    
    ; CHECK PAUSE 'P' (Scan code 0x19)
    cmp ah, 0x19
    je pauseGame

    call movePaddle
    call printPaddle 
	call playPaddleSound	
    jmp check_win_loss

no_key_pressed:
    call printPaddle        

check_win_loss:
    mov ax,[lives]
    cmp ax,0
    je gameOver
    mov ax,[score]
    cmp ax,3120
    je gameWin
    
    jmp mainLoop            

skip_to_exit:
    call unhook_timer       
    jmp skip
gameWin:
    call unhook_timer       
	call printGameWinScr
waitWinInput:
	mov ah,0
	int 0x16
	cmp ah,0x01          ; Esc
	je skip
	cmp ah,0x13          ; 'R'
    je doRestart
	jmp waitWinInput

gameOver:
    call unhook_timer       
	call printGameOverScr
waitLossInput:
	mov ah,0
	int 0x16
	cmp ah,0x01          ; Esc
	je skip
	cmp ah,0x13          ; 'R'
    je doRestart
	jmp waitLossInput

doRestart:
    call resetGameVars
    call playGame

skip:
    call unhook_timer       
    call printEscapeScr
	jmp finish
    ret

playGame:
	call WelcomeScr
	call gameTopRow
	call gameLeftMostColumn
	call gameBottomRow
	call gameRightMostColumn
	call gameDividerColumn
	call rightCompartmentDivider
	call printScoreDisplay
	call printLifeDisplay
	call gameRedBrickRow
	call gameYellowBrickRow
	call gameGreenBrickRow
	call printPaddle
	call printBall
	call gameloop
	ret
	
start:
    call resetGameVars      
    call clrscr
    call printWelcomeScr
    call pressKeys
    call printGameMenu
    call pressKeys1
finish:
    mov ax,0x4c00
    int 0x21