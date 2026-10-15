%UWAGA!!! NALEZY UWAZAC NA NAZWY ZMIENNYCH,, sa troche inne niz w skrypcie
%
%C
%======== I cz (indentyfikacja) ======
% wartści nominalne
TzewN=-20; %oC
Twew1N=20; %oC
Twew2N=15; %oC
Tw1N = 30; 
Tw2 = 15;
PkN = 10000; %kW
a = 0.6;
%Ks1 = 150;
%K0 = 800;
%Ks2=284.57;
cpp = 1000;
rop = 1.2;

%param stat
FpN = PkN/(cpp*rop*(Tw1N - Twew1N)); %%0.833;
Ks1 = a*PkN / (Twew1N - TzewN); %%150
K0 = (1 - a)*PkN / (Twew1N - Twew2N) %%800
Ks2 = cpp*rop*FpN*(Tw1N - Twew1N)/(Twew2N-TzewN) %284.57



fprintf('fpN = %.4f\n', FpN);
fprintf('Ks2 = %.4f\n', Ks2);
fprintf('Ks1 = %.4f\n', Ks1);
fprintf('K0  = %.4f\n', K0);

