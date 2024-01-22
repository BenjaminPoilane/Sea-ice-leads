function [M01]=calculDeM0(MatriceDesDonnees,scalePix)
% Methode qui prend en entree un matrice de donnees (image matricielle), un
% masque de meme format que la matrice des donnes (1 lorsqu'il y a des
% donnes 0 sinon), et une echelle d'analyse en pixels: scalePix


% Il faut que l'echelle en pixel (maintenant appelée 'l' ) soit impaire : 
l=scalePix+(1-mod(scalePix,2)); 

% On calcul les indices [imin, imax, jmin, jmax] tels que tous les coeffs
% non nuls de la matrice des donnees soient compris dans ces indices
[imin,imax,jmin,jmax]=matriceUtile(MatriceDesDonnees>0);

% Pour gagner du temps, on n'appliquera la methode qu'à la matrice extraite
% de 'MatriceDesDonnes' comprise entre [imin-l, jmin-l, imax+l, jmax+l].
% On completera avec des zeros ensuite.
imin=max(1,imin-l);
imax=min(size(MatriceDesDonnees,1),imax+l);
jmin=max(1,jmin-l);
jmax=min(size(MatriceDesDonnees,2),jmax+l);
M=double(MatriceDesDonnees(imin:imax,jmin:jmax));
[n,m]=size(M);

% INITIALISATION DES SORTIES :
M0=zeros(n,m);          % M0(i,j) est la somme des coeffs de M compris dans le disque d'analyse centré en (i,j) de diamètre l.

% indices du centre du premier disque d'analyse 
i0=(l+1)/2;
j0=(l+1)/2;

contd=contourCirculaire(l,'droite'); % Limite à droite du disque d'analyse
contg=contourCirculaire(l,'gauche'); % Limite à gauche du disque d'analyse
conth=contourCirculaire(l,'haut');   % Limite en haut du disque d'analyse
contb=contourCirculaire(l,'bas');    % Limite en bas du disque d'analyse

% direction est la direction de progression du disque. Initialisee à [0,1],
% meme ligne, une colonne en plus, c'est-à-dire vers la droite.
direction=[0,1];
memoireDirection=[0,1];

%contour qui sera perdu lorsque le disque d'analyse va avancé:
contPrec=contg;

%contour qui vient d'être gagné lorsque le disuqe d'analyse à avancé:
contSuiv=contd;

% Les mab (ou a,b= 0,1,2 ) sont des coeffs qui servent à calculer les
% coeffs de la matrice d'inertie du disque d'analyse.
% mab= Somme pour (i,j) dans le disque des M(i,j)*(i-i0)^a * (j-j0)^b 
% où i0,j0 sont les coordonnées du centre du disque.
m0=0;
% Initialisation des ces coeffs pour le premier disque d'analyse:

for i=1:l
    for j=1:l
        if (i-i0)^2+(j-j0)^2<=(l/2)^2
            m0=m0+M(i,j);
        end
    end
end


% Début du parcours de l'image par le disque d'analyse
while i0+j0<n+m-2*(l-1)/2   
    
% Définition de contPrec et contSuiv de la prochaine iteration en fonction de la direction d'avancement du disque    
    
% Si la direction va vers la droite ([0,1]) ou vers la gauche ([0,-1]):    
    if direction(2)==1
        contPrec=contg;
        contSuiv=contd;
    end
    if direction(2)==-1
        contPrec=contd;
        contSuiv=contg;
    end
    
% Si la direction est vers le bas, l'avancement va se faire soit vers la
% gauche, soit vers la droite en fonction de l'avancement d'avant
% (memoireDirection)
    if direction(1)==1
        if memoireDirection(2)==1
            direction=[0,-1];
            contPrec=contd;
            contSuiv=contg;
        end
        if memoireDirection(2)==-1
            direction=[0,1];
            contPrec=contg;
            contSuiv=contd;
        end
        memoireDirection=direction;
    end
    
% Si on est en bout de ligne :     
    if direction(2)==1 && j0+(l-1)/2>=m
        memoireDirection=direction;
        direction=[1,0]; 
        contPrec=conth;
        contSuiv=contb;
    end
    if direction(2)==-1 && j0-(l-1)/2<=1
        memoireDirection=direction;
        direction=[1,0];
        contPrec=conth;
        contSuiv=contb;
    end  
    
% on fait avancer (i0,j0)
    i0=i0+direction(1);
    j0=j0+direction(2);

% On retire les contributions de contPrec
    m0=m0-somme1(contPrec,M,0,0,i0,j0);
    
% On met à jour les contours du disque d'analyse :   
    contg(:,1)=contg(:,1)+direction(1);
    contd(:,1)=contd(:,1)+direction(1);
    conth(:,1)=conth(:,1)+direction(1);
    contb(:,1)=contb(:,1)+direction(1);
    contg(:,2)=contg(:,2)+direction(2);
    contd(:,2)=contd(:,2)+direction(2);
    conth(:,2)=conth(:,2)+direction(2);
    contb(:,2)=contb(:,2)+direction(2);
    
% On met à jour contSuiv:    
    contSuiv(:,1)=contSuiv(:,1)+direction(1);
    contSuiv(:,2)=contSuiv(:,2)+direction(2);
% On rajoute aux mab la contribution de contSuiv   
    m0=m0+somme1(contSuiv,M,0,0,i0,j0);    
    M0(i0,j0)=m0;

end

% On complete maintenant nos matrices par des zeros pour avoir la meme
% taille que MatriceDesDonnees:


M01=zeros(size(MatriceDesDonnees));
M01(imin:imax,jmin:jmax)=M0;

return;
end
function tot=somme1(c,M,expi,expj,i0,j0)
% Calcul somme des M(i,j)*(i-i0)^expi * (j-j0)^expj où les valeurs de i et
% j sont données par c ( liste des i: c(:,1); liste des j: c(:,2) )

    s=size(c);
    tot=0;
    for k=1:s(1)
        tot=tot+M(c(k,1),c(k,2))*((c(k,1)-i0)^expi)*((c(k,2)-j0)^expj);
    end
    return
end
function p=ponder(m,l)
% Calcul le ponderateur
    if m<l
        p=m/l;
    else
        p=1;
    end
    return
end

