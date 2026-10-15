clear; clc; close all;

% 1. Parametry fizyczne materiałów i płynów
cpp = 1000;   % Ciepło właściwe powietrza [J/(kg*K)]
rhop = 1.2;   % Gęstość powietrza [kg/m^3]
cpo = 2400;   % Ciepło właściwe oleju [J/(kg*K)]
rhoo = 1200;  % Gęstość oleju [kg/m^3]

% 2. Objętości i parametry grzejnika oraz pokoi
Vw1 = 2.5 * 6;       % Objętość pokoju 1 [m^3]
Vw2 = 2.5 * 4;       % Objętość pokoju 2 [m^3]
Vg1 = 15 / 1000;     % Objętość oleju w grzejniku pokoju 1 [m^3] (15 litrów)

% 3. Pojemności cieplne
Cvw1 = cpp * rhop * Vw1;   % Pojemność cieplna pokoju 1 [J/K]
Cvw2 = cpp * rhop * Vw2;   % Pojemność cieplna pokoju 2 [J/K]
Cvg1 = cpo * rhoo * Vg1;   % Pojemność cieplna grzejnika olejowego [J/K]

% 4. Warunki początkowe (stan nominalny)
TzewN = -20;  % Temperatura zewnętrzna [°C]
Twew1N = 20;  % Temperatura w pokoju 1 [°C]
Twew2N = 20;  % Temperatura w pokoju 2 [°C]
Tg1N = 35;    % Temperatura grzejnika w pokoju 1 [°C]
Pg1N = 2000;  % Nominalna moc grzałki w pokoju 1 [W]

% 5. Współczynniki strat ciepła i wymiany
K1_z = 30;    % Straty ciepła z pokoju 1 na zewnątrz [W/K]
K2_z = 20;    % Straty ciepła z pokoju 2 na zewnątrz [W/K]
K12 = 25;     % Wymiana ciepła między pokojem 1 a pokojem 2 [W/K]
Kg1 = 180;    % Współczynnik wymiany ciepła między grzejnikiem a pokojem 1 [W/K]

% 6. Konfiguracja czasu symulacji i kroku pętli
dt = 1;            % Krok czasowy [s]
czas_max = 3600 * 4;  % Czas całkowity [s] (4 godziny)
t = 0:dt:czas_max; % Wektor czasu
N = length(t);

t_on = 600;        % Włączenie grzania [s] (10. minuta)
t_off = 3600 * 2;  % Wyłączenie grzania [s] (2. godzina)

% Inicjalizacja wektorów wyników
Tg1 = zeros(1, N);
Twew1 = zeros(1, N);
Twew2 = zeros(1, N);
Pg1_history = zeros(1, N);

% Warunki początkowe
Tg1(1) = Tg1N;
Twew1(1) = Twew1N;
Twew2(1) = Twew2N;

% 7. Pętla symulacyjna (Metoda Eulera dla układu: Grzejnik + 2 Pokoje)
for i = 1:(N-1)
    current_t = t(i);
    
    % Sterowanie mocą grzałki (impuls)
    if current_t >= t_on && current_t <= t_off
        Pg1 = Pg1N;
    else
        Pg1 = 0;
    end
    Pg1_history(i) = Pg1;
    
    % Równania różniczkowe:
    % 1. Dynamika temperatury grzejnika olejowego
    dTg1_dt = (1 / Cvg1) * (Pg1 - Kg1 * (Tg1(i) - Twew1(i)));
    
    % 2. Bilans ciepła w pokoju 1 (zasilany przez grzejnik, traci na zewnątrz i do pokoju 2)
    dTwew1_dt = (1 / Cvw1) * (Kg1 * (Tg1(i) - Twew1(i)) - K1_z * (Twew1(i) - TzewN) - K12 * (Twew1(i) - Twew2(i)));
    
    % 3. Bilans ciepła w pokoju 2 (ogrzewany pośrednio przez ścianę z pokoju 1)
    dTwew2_dt = (1 / Cvw2) * (K12 * (Twew1(i) - Twew2(i)) - K2_z * (Twew2(i) - TzewN));
    
    % Całkowanie numeryczne (Euler)
    Tg1(i+1) = Tg1(i) + dTg1_dt * dt;
    Twew1(i+1) = Twew1(i) + dTwew1_dt * dt;
    Twew2(i+1) = Twew2(i) + dTwew2_dt * dt;
end
Pg1_history(N) = Pg1_history(N-1);

% Przeliczenie czasu na minuty
t_min = t / 60;

% 8. Wykres mocy grzejnika (Wejście - CV)
figure('Theme', 'light');
plot(t_min, Pg1_history, 'm-', 'LineWidth', 1.5);
grid on;
title('Moc grzałki elektrycznej w grzejniku olejowym (P_{g1})');
xlabel('Czas [min]');
ylabel('Moc [W]');
ylim([-200, 2400]);

% 9. Wykres temperatur (Grzejnik + oba pokoje)
figure('Theme', 'light');
plot(t_min, Tg1, 'r-', 'LineWidth', 1.5);
hold on;
plot(t_min, Twew1, 'b-', 'LineWidth', 1.5);
plot(t_min, Twew2, 'g-', 'LineWidth', 1.5);
grid on;
title('Odpowiedź temperatur w układzie z grzejnikiem olejowym i dwoma pokojami');
xlabel('Czas [min]');
ylabel('Temperatura [°C]');
legend('Temperatura grzejnika T_{g1}', 'Pokój 1 (z grzejnikiem) T_{wew1}', 'Pokój 2 (bez grzejnika) T_{wew2}', 'Location', 'Southeast');
