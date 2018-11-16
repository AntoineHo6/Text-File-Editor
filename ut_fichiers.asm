;;; ut_fichiers.asm
;;; Fichier comprenant des fonctions utilitaires de gestion de fichiers
;;;
;;; Auteur: Eric Wenaas

	
	segment .data

skipLigne:		db 10

	segment .bss

	segment .text

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Fonction qui retourne la taille d'un fichier
;;;
;;; Entrée: Le nom du fichier (ESP + 8)
;;; Sortie: La taille du fichier (ESP + 4)
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
	
taille_fichier:	
	push ebp
	mov ebp, esp
	sub esp, 64		; Espace pour les stats (ebp - 64)
	push eax
	push ebx
	push ecx

	mov ebx, [ebp+12]	; Le nom du fichier
	mov eax, 106		; Appel systeme
	lea ecx, [ebp-64]	; La structure pour stocker les informations
	int 0x80		; Obtient les stats sur le fichier
	
	add ecx, 20		; 20 est le deplacement pour la taille dans struct stat
	mov eax, [ecx]		
	mov [ebp+8], eax	; Et on met la reponse dans la pile
	
	;; On sort
	pop ecx
	pop ebx
	pop eax
	add esp, 64
	pop ebp
	ret

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Fonction qui détermine si un fichier existe. Si
;;; c'est le cas, elle retourne 1. Sinon, elle retourne 0
;;;
;;; Entrée: le nom du fichier (ESP + 8)
;;; Sortie: si le fichier existe 1 sinon 0 (ESP + 4)
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fichier_existe:
	push ebp
	mov ebp, esp
	push eax
	push ebx
	push ecx
	sub esp, 64

	mov ecx, esp
	mov eax, 106
	mov ebx, [ebp + 12]
	int 0x80

	cmp eax, 0
	jne absent
	mov dword [ebp+8], 1
	jmp sortir
absent:
	mov dword [ebp+8], 0
	
sortir:	
	add esp, 64
	pop ecx
	pop ebx
	pop eax
	pop ebp
	ret


;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Fonction qui ouvre un fichier dans le mode passé en
;;; paramètre. Les permissions du fichier sont 644.
;;;
;;; Entrée: Le mode d'ouverture (ESP + 8)
;;; Entrée: Le nom du fichier (ESP + 12)
;;; Sortie: Le descripteur de fichier (ESP + 4)
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ouvrir_fichier:
	push ebp
	mov ebp, esp
	push eax
	push ebx
	push ecx
	push edx
	
	mov eax, 5
	mov ebx, [ebp + 16]
	mov ecx, [ebp + 12]
	mov edx, 644o
	int 0x80

	mov [ebp + 8], eax
	pop edx
	pop ecx
	pop ebx
	pop eax
	pop ebp
	ret

;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Fonction qui se déplace dans un fichier. Le point de
;;; départ en fonction du déplacement est 0.
;;;
;;; Entrée: Le descripteur de fichier (ESP + 4)
;;; Entrée: Le déplacement dans le fichier (ESP + 8)
;;; Effet:  Le pointeur avance dans le fichier en fonction
;;;         du déplacement.
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
deplacer_fichier:
	push ebp
	mov ebp, esp
	push eax
	push ebx
	push ecx
	push edx

	mov eax, 0x13
	mov ebx, [ebp + 8]
	mov ecx, [ebp + 12]
	mov edx, 0
	int 0x80

	pop edx
	pop ecx
	pop ebx
	pop eax
	pop ebp
	ret


;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 
;;; 
;;;	Saute une ligne dans le fichier
;;; 
;;; 
;;; 
;;; 
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
sauteLigneFichier:
	push 1
	push skipLigne
	push dword [descFichier]
	call ecrireFichier
	add esp, 12
	ret


;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; 
;;; 
;;;	Stock la taille du fichier
;;; 
;;; 
;;; 
;;; 
;;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
stockTailleFichier:
	push dword [nom_fich]
 	push 0
 	call taille_fichier
	pop dword [tailleFichier]
 	add esp, 4
	ret
