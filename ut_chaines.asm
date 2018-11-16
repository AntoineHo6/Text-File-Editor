;;; ut_chaines.asm
;;; Fichier contenant des procedures utilitaires pour le traitement des chaines
;;;
;;; Auteur: Eric Wenaas

	segment .data

msgErreurArg:		db "Il ne faut que le nom du fichier", 0
	
msgErreurLenChaine:	db "La chaine est trop longue", 0

msgEntrerChaine:	db "Entrez une chaine: ", 0
	
	
	segment .bss
	
	segment .text
	
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;push msgErreurArg
	call affiche
	add esp, 4
	jmp sortie
;;; Procedure qui fait une nouvelle ligne 
;;;             
;;; Aucun paramètre
;;;
;;; Effet : Une nouvelle ligne est affichée à
;;;         la sortie standard
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

nouvelle_ligne:
	push ebp
	mov ebp, esp
	
	sub esp, 4		; Endroit pour la variable contenant le retour
	mov byte [ebp-4], 10   ; Place le retour dans la variable
	
	push eax		; Sauvegarde des registres
	push ebx
	push ecx
	push edx
	
	mov eax, 4
	mov ebx, 1
	lea ecx, [ebp - 4]
	mov edx, 1
	int 0x80
	
	pop edx			; Restauration des registres
	pop ecx
	pop ebx
	pop eax
	add esp, 4		; Enleve les variables locales

	pop ebp
	ret

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Fonction qui retourne la taille de la chaine
;;;
;;; Entrée: Adresse du premier caractère de la chaîne. (ESP + 8)
;;; Sortie: Taille de la chaine (ESP + 4)
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
taille_ch:
	push ebp
	mov ebp, esp
	push eax
	push ebx

	mov ebx, [ebp + 12]
	xor eax, eax

b_taille:
	cmp byte [ebx], 0	; Est-ce le caractere nul
	je fin_taille
	inc eax			; Un caractere de plus
	inc ebx			; On passe au suivant
	jmp b_taille
	
fin_taille:
	mov [ebp + 8], eax	; Place le resultat sur la pile

	pop ebx
	pop eax
	pop ebp
	ret

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Procédure qui affiche une chaine de caracteres sans changer de ligne
;;;
;;; Entrée: Adresse du premier caractere de la chaine
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

affiche:
	push ebp
	mov  ebp, esp
	push eax
	push ebx
	push ecx
	push edx

	mov eax, 4
	mov ebx, 1
	mov ecx, [ebp + 8]

	;; Appel de la fonction taille_ch
	push ecx
	push 0			; pour la taille
	call taille_ch
	pop  edx		; edx prend la taille
	add esp, 4		; enleve un parametre

	int 0x80

	pop edx
	pop ecx
	pop ebx
	pop eax
	pop ebp
	ret

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Procédure qui affiche une chaine de caracteres et change de ligne
;;;
;;; Entree: Adresse du premier caractere de la chaine (ESP + 4)
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
affiche_nl:
	push dword [esp + 4]
	call affiche
	add  esp, 4
	call nouvelle_ligne
	ret


;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Procédure qui fait la lecture d'une chaine d'une taille maximale et
;;; la place vis-a-vis la chaine. Le tampon est vidé est nécessaire.
;;; Retourne -1 si la chaine etait trop longue.
;;;
;;; Entrée: L'adresse d'une chaine de caracteres (ESP + 8)
;;; Entrée: La taille maximale de la chaine incluant le caractere nul (ESP + 12)
;;; Sortie: Le nombre de caracteres effectivement lus (ESP + 4)
;;;
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
lire_ch:
	push ebp
	mov ebp, esp
	push eax
	push ebx
	push ecx
	push edx

	;; On fait la lecture
	mov eax, 3
	mov ebx, 0
	mov ecx, [ebp + 12]	; la chaine
	mov edx, [ebp + 16]	; la taille maximale
	int 0x80

	dec eax	     		; Ignore le retour dans le nombre de caracteres lus
	add ecx, eax		
	cmp byte [ecx], 10	; On regarde si le dernier caractere est un retour
	je  chaine_ok
	call vider_tampon
	mov eax, -1 		; Il faut vider le tampon, la chaine est invalide, on retourne -1
	mov byte [ebp + 12], 0  ; Caractere nul sur le premie caractere de la chaine
	
chaine_ok:
	mov byte [ecx], 0	; On place le caractere nul a la fin de la chaine
	mov [ebp + 8], eax	; On retourne la taille de la chaine
	
	pop edx
	pop ecx
	pop ebx
	pop eax
	pop ebp
	ret
	
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Cette procedure vide le tampon, Ne pas appeler si le
;;; tampon est deja vide.
;;;
;;; Aucun parametre
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
vider_tampon:
	push eax
	push ebx
	push ecx
	push edx

	add  esp, 4		; variable locale bidon

vider:	
	mov eax, 3
	mov ebx, 0
	mov ecx, esp
	sub ecx, 4		; on lit sur la variable locale bidon
	mov edx, 1
	int 0x80

	cmp byte[esp-4], 10
	jne vider
	sub esp, 4
	
	pop edx
	pop ecx
	pop ebx
	pop eax

	ret


;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Ecrit dans un fichier
;;;             
;;; Entrée: Descripteur du fichier (ESP + 8)
;;; Entrée: La chaine (ESP + 12)
;;; Entrée: Taille de la chaine (ESP + 16)
;;;         
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ecrireFichier:
	push ebp
	mov ebp, esp
	push eax
	push ebx
	push ecx
	push edx

	;; ecriture dans le fichier
	mov eax, 4
	mov ebx, [ebp + 8] 	; Descripteur du fichier
	mov ecx, [ebp + 12] 	; La chaine
	mov edx, [ebp + 16]	; Taille de la chaine
	int 0x80

	pop edx
	pop ecx
	pop ebx
	pop eax
	pop ebp
	ret


;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 
;;; Affiche le message d'erreur sur le nombre d'arguments 
;;;
;;; 
;;; 
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
affichageErreurArg:
	push msgErreurArg
	call affiche_nl
	add esp, 4
	ret


;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 
;;; Affiche le message d'erreur sur la taille de la chaine
;;;
;;; 
;;; 
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
affichageErreurLenChaine:
	push msgErreurLenChaine
	call affiche_nl
	add esp, 4
	ret

	
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 
;;; Affiche le message d'entrer une chaine
;;;
;;; 
;;; 
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
affichageDemandeChaine:
	push msgEntrerChaine
	call affiche
	add esp, 4
	ret
