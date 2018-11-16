;;; Auteur: Antoine Ho

%include "ut_chaines.asm"
%include "ut_fichiers.asm"
	
segment .data

segment .bss

nom_fich:		resd 16
chaine:			resd 81
lenChaine:		resd 1
compteurLigneVide:	resd 1

descFichier:		resd 42
existanceFichier:	resb 1
tailleFichier:	 	resd 42

compteurTest:		resd 200

segment .text

	global _start  
_start:
	mov edi, 4
	mov ecx, [esp]
	

;;; verifie si la commande precedente contient 2 arguments
;;; Si c'est faux, il quitte
	xor eax, eax		; initialise eax à 0 pour compter le nombre d'argument
verifieDeuxArg:
	push dword [esp + edi]
	inc eax
	
	pop dword [nom_fich]
	push dword [nom_fich]
	
	add esp, 4
	add edi, 4
	loop verifieDeuxArg

	;; Verifie si il y a strictement 2 arguments
	cmp eax, 2
	jne erreurArg


;;; Verifie si le fichier existe ou non
verifieFichEx:
	push dword [nom_fich]
	push 0
	call fichier_existe
	pop dword [existanceFichier]
	add esp, 4

	cmp dword [existanceFichier], 1
	je ouvertureAppend
	

;;; Créé un nouveau fichier
creationFichier:
	push dword [nom_fich]
	push 101o
	push 0
	call ouvrir_fichier
	pop dword [descFichier]
	add esp, 8
	jmp lectureChaine
	
	
;;; Ouvre un fichier existant en mode append
ouvertureAppend:
	push dword [nom_fich]
	push 201o
	push 0
	call ouvrir_fichier
	pop dword [descFichier]
	add esp, 8

	;; Stock la taille du fichier dans tailleFichier
	;; Le sous-programme est dans ut_fichiers.asm
	call stockTailleFichier

	;; On se met a la fin du fichier
	push dword [tailleFichier]
	push dword [descFichier]
	call deplacer_fichier
	add esp, 8
	

;;; L'utilisateur entre une ligne pour entrer dans le fichier
lectureChaine:		
	;; Affiche un message qui demande a l'utilisateur d'entrer une chaine
	;; le sous-programme est dans ut_chaines.asm
	call affichageDemandeChaine

	;; demande une chaine
	push 81
	push chaine
	push 0
	call lire_ch
	pop dword [lenChaine]
	add esp, 8

	cmp dword [lenChaine], 0
	je chaineVide

	cmp dword [lenChaine], -1
	je erreurLenChaine
	

;;; Ecrit la chaine dans le fichier
;;; Le sous-programme ecrireFichier a été ajouté dans ut_chaines.asm
ecritureFichier:
	mov dword [compteurLigneVide], 0

	push dword [lenChaine]
	push chaine
	push dword [descFichier]
	call ecrireFichier
	add esp, 12

	;; ecrit dans le fichier pour sauter de ligne
	;; Le sous-programme est dans ut_fichiers.asm
	call sauteLigneFichier
	
	jmp lectureChaine



;;; Sort du programme
sortie:
	mov eax, 6
	mov ebx, dword [descFichier]
	int 0x80

	mov eax, 1
	mov ebx, 0
	int 0x80

;;; Sortie d'erreur
sortieErreur:
	mov eax, 1
	mov ebx, 2
	int 0x80


;;; Affiche un message d'erreur et sort du programme
;;; (erreur: Le nombre d'argument entré est incorrect)
;;; Le sous-programme affichageErreurArg est dans ut_chaines.asm
erreurArg:
	call affichageErreurArg
	jmp sortieErreur

	
;;; Affiche un message d'erreur et sort du programme
;;; (erreur: Longueur de la chaine est trop longue)
;;; Le sous-programme affichageErreurLenChaine est dans ut_chaines.asm
erreurLenChaine:
	call affichageErreurLenChaine
	jmp lectureChaine
	

;;; Incrémente le compteur de ligne vide
;;; et saute une ligne dans le fichier
chaineVide:
	add dword [compteurLigneVide], 1

	cmp dword [compteurLigneVide], 2
;;	je afficheText	

	cmp dword [compteurLigneVide], 3
	je sortie

	;; ecrit dans le fichier pour sauter de ligne
	call sauteLigneFichier

	jmp lectureChaine








