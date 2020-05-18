%Day|Month|Year|Hour| Minute |Ubat[Vdc]| Ibat(m)[Adc] | Ubatmin [Vdc] | Uin [Vac] |Iin[Aac] | P out [kVA] | P out max [kVA] |  F out [Hz] |  Phase [] | Mode [] |Transfert  |  RME [] | Aux 1 [] | Aux 2 [] | F in [Hz] | P in a [W] | Pout a [W] |  T_elec1 [°C] | BSP U_bat [V] | BSP I_bat [A] | BSP SOC [%] | BSP Tbat [°C] | XCOM MS Pout [kW] | U bat ond [Vrip] | Minigrid [Vdc] | E in tot [dkWh] | E qu [kWh]  |
% 1 | 2   |  3 | 4  |   5    |    6    |     7        |      8        |        9  |     10  |     11      |       12        |     13      |      14   |    15   |    16     |   17    |    18    |   19     |    20     |     21     |    22      |       23      |      24       |      25       |      26     |       27      |        28         |        29        |       30       |        31       |      32     |
%




D= day_data;

A= 1:length(D);

nm=1; %начален момент на гр
krm=length(D(:,1))

% Определяне на енергията от и към батерията
E_bat_in=0;
E_bat_out=0;
E_gen=0;
E_tow=0;

Uin = zeros(length(D),1);
Iin = zeros(length(D),1);
Ubat_inv = zeros(length(D),1);
Ibat_inv = zeros(length(D),1);
Ubat_BSP = zeros(length(D),1);
Ibat_BSP = zeros(length(D),1);
Ibat_PV = zeros(length(D),1);
Pbat_inv = zeros(length(D),1);
Pbat_BSP = zeros(length(D),1);
Ubat_PV = zeros(length(D),1);
Pbat_PV = zeros(length(D),1);
Temp_bat= zeros(length(D),1);
SOC_BSP= zeros(length(D),1);

Pgen = zeros(length(D),1);
Ptow = zeros(length(D),1);
Ttow = zeros(length(D),1);
kpd_charge = zeros(length(D),1);
kpd_inv = zeros(length(D),1);

for k= 1:length(D)
    
    Ubat_inv(k,1) = D(k,19); % напрежение на батерията, Vdc
    Ibat_inv(k,1) = D(k,20); % ток на батерията, Adc
    Uin(k,1) = D(k,7); % напрежение на генератора, Vac
    Iin(k,1) = D(k,8); % напрежение на генератора, Vac
    Ubat_BSP (k,1) = D(k,24); % напрежение на батерията, измерена от BSP, Vdc
    Ibat_BSP (k,1) = D(k,25);    % ток на батерията, измерен от BSP, Adc
    SOC_BSP(k,1) = D(k,26);    % ток на батерията, измерен от BSP
    Pgen(k,1) = D(k,21); % мощност на генератора, W
    Ptow(k,1) = D(k,22)*1000; % мощност на товара, VA
    Pbat_inv(k,1) = Ubat_inv(k,1).*Ibat_inv(k,1); % DC мощност на инвертора, W
    Pbat_BSP(k,1)= Ubat_BSP(k,1).*Ibat_BSP(k,1); % мощност от/към батерията, W
    %KPD_inv_DC_AC=  (k,1)
    Temp_bat(k,1)= D(k,23); % температура на батерията, градуси
    
    Ibat_PV(k,1) = Ibat_BSP(k,1)-Ibat_inv(k,1); %ВАЖНО може би
    Ubat_PV(k,1)= Ubat_BSP(k,1);
    Ploss=((Ubat_inv(k,1)-Ubat_BSP(k,1)).*Ibat_BSP(k,1));
    if Uin(k,1)>100
        Pbat_PV(k,1)=0;
    else
    Pbat_PV(k,1)=Ubat_PV(k,1).*Ibat_PV(k,1);
    end
%     deltaUvr(k,1)=Ubat_inv(k,1)-Ubat_BSP(k,1);
%     Rvryzka(k,1)=(Ubat_inv(k,1)-Ubat_BSP(k,1))./Ibat_BSP(k,1);
%     
    
    %Енергия от и към батерията
    if Pbat_BSP(k,1)>0
        E_bat_in= E_bat_in + (Pbat_BSP(k,1)/60)/1000; %енергия вкарана в батерията, kWh
    elseif Pbat_BSP(k,1)<0
        E_bat_out= E_bat_out + (Pbat_BSP(k,1)/60)/1000; %енергия изкарана от батерията, kWh
    end
    
    E_gen= E_gen+ ((Uin(k,1)*Iin(k,1))/60)/1000; %енергия подадена от генератора, kWh;
    E_tow= E_tow+ ((Ptow(k,1))/60)/1000; %енергия консумирана от товара, kWh
    
    
    Ttow(k,1)=(60*D(k,4)+D(k,5))/60;
    
    if Uin(k,1) >= 210
        kpd_charge(k,1) = Pbat_inv(k,1)/(Pgen(k,1)-Ptow(k,1));
    elseif Uin(k,1) < 210
        kpd_inv(k,1) = ((Ubat_inv(k,1)*Ibat_inv(k,1))/Ptow(k,1));
    end
    
end

KPD_bat=E_bat_out/E_bat_in



time_period=2% времеви период 1-минути; 2-часове; 3- дни
if time_period==1 % минути
    t=A;
    time_label='t, мин.';
elseif time_period==2 %часове
    t=A/60;
    time_label='t, ч';
elseif time_period==3 %дни
    t= A/(60*24);
    time_label='t, дни';
end

E_pv = abs(E_bat_out)- abs( E_bat_in)
e = E_tow/ E_gen


%НАЧАЛО НА ПИСАНЕТО НА ДАННИТЕ В МАТЛАБ ФАЙЛ
myfile = fullfile('C:\Полигона\Докторантура\Статия модел батерия','battery2019.mat');       
matObj = matfile(myfile,'Writable',true);

  for k = 6:length(D) 
           
       %if D(k,19)< 30
          
       %   matObj.Vbat(k,1)= matObj.Vbat(k-1,1);
       %else    
       %    matObj.Vbat(k,1) = D(k,19);  % напрежението на батерията
       %end
%       matObj.Ibat(k,1) = D(k,20);  % ток на батерията
%       matObj.SOC(k,1) = D(k,26);   % SOC на батерията   
      %matObj.Ptow(k,1) = -D(k,22)*1000; % мощност на товара, VA
      matObj.Ibat_BSP(k,1) = Ibat_BSP (k,1); %D(k,25);
      
      
      if Ibat_PV (k,1) < -4 %&& k > 5 
          matObj.Ibat_PV(k,1) = -2; %Ibat_PV(k-1,1);
       else         
          matObj.Ibat_PV(k,1) = Ibat_PV (k,1);
      end
          
  end

  counter=0
  
for i= 6:length(D)-5  % ТАКА НЯМА ДА СЛОЖИ ПОСЛЕДНИТЕ 5 БРОЙКИ ОТ ГОДИНАТА
    
    mean_back_value = (Ibat_PV(i-1,1) + Ibat_PV(i-2,1) + Ibat_PV(i-3,1) + Ibat_PV(i-4,1) + Ibat_PV(i-5,1))/5;
    mean_forward_value = (Ibat_PV(i+1,1) + Ibat_PV(i+2,1) + Ibat_PV(i+3,1) + Ibat_PV(i+4,1) + Ibat_PV(i+5,1))/5;
    
   if Ibat_PV(i,1) > 2 && mean_back_value < 0 && mean_forward_value < 0 %Ibat_PV (i,1) > 2.2* abs(mean_back_value) && Ibat_PV (i,1) > 2.2* abs(mean_forward_value)
       matObj.Ibat_PV(i,1) = mean_back_value;
       counter= counter + 1
   end
end

krm= 10*24*60

% figure(1)
% plot (t(1,nm:krm),Ubat_inv(nm:krm,1)   ) , xlabel(time_label), ylabel('Uген,V'); grid;
% title ('{\bf\it STATUS PV  } \copyright 2003-2012'); % Задава заглавие на чертежното поле
% %axis([0  0 1.50])

% figure(3)
% subplot (2,1,1);
% plot (t,matObj.Vbat(nm:krm,1)   ) , xlabel(time_label), ylabel('Uбат,V'); grid;
% title ('{\bf\it STATUS PV  } \copyright 2003-2012'); % Задава заглавие на чертежното поле
% legend ( 'Напрежение на батерията, V')
% 
% subplot (2,1,2); 
% plot (t,matObj.SOC(nm:krm,1)  ) , xlabel(time_label), ylabel('SOC,%'); grid;
% legend ( 'SOC на батерията, %')
% %title ('{\bf\it STATUS PV  } \copyright 2003-2012'); % Задава заглавие на чертежното поле

% figure(2)
% plot (Ttow,Ptow,' o','LineWidth',1,'MarkerSize',4)  , xlabel(time_label), ylabel('Pтов,W'); grid;
% title ('{\bf\it STATUS PV  } \copyright 2003-2012'); % Задава заглавие на чертежното поле

% figure(4)
% subplot (3,1,1); plot (t(1,nm:krm),Ibat_inv(nm:krm,1)), xlabel(time_label), ylabel('I, A'); grid;
% legend ( 'Ток на батерията от инвертора, A' )
% title ('{\bf\it STATUS PV  } \copyright 2003-2012'); % Задава заглавие на чертежното поле
% 
% subplot (3,1,2); plot ( t(1,nm:krm),Ibat_BSP(nm:krm,1)), xlabel(time_label), ylabel('I, A'); grid;
% legend ( 'Ток на батерията Iбат BSP, A' )
% 
% 
% subplot (3,1,3); plot ( t(1,nm:krm), Ibat_PV(nm:krm,1) ) , xlabel(time_label), ylabel('I, A'); grid;
% legend ( 'Ток на батерията от PV, A' )


% figure(8)
% subplot (2,1,1); plot (t,Ubat_inv.*Ibat_inv,   t,Pgen, t,-Ptow , t, Pbat_PV ) , xlabel(time_label), ylabel('P, W'); grid;
% legend ( 'Мощност от/към инвертора Pинв=>бат, W', 'Мощност от дизел генератора Pген, W',  'Мощност на товара Pтов, W', 'Мощност от/към PV, W')
% title ('{\bf\it STATUS PV  } \copyright 2003-2012'); % Задава заглавие на чертежното поле
% 
% subplot (2,1,2); plot (t,Ubat_inv   ) , xlabel(time_label), ylabel('Uбат,V'); grid;
% legend ( 'Напрежение на батерията, V')
% %title ('{\bf\it STATUS PV  } \copyright 2003-2012'); % Задава заглавие на чертежното поле


figure(9)
subplot (2,1,1); plot (t(1,nm:krm),Ibat_inv(nm:krm,1) ) , xlabel(time_label), ylabel('I, A'); grid;
legend ( 'Ток на батерията Iбат, A')
title ('{\bf\it STATUS PV  } \copyright 2003-2012'); % Задава заглавие на чертежното поле

subplot (2,1,2); plot (t(1,nm:krm),Ubat_inv(nm:krm,1)   ) , xlabel(time_label), ylabel('Uбат,V'); grid;
legend ( 'Напрежение на батерията, V')
title ('{\bf\it STATUS PV  } \copyright 2003-2012'); % Задава заглавие на чертежното поле

figure(10)
subplot (3,1,1); plot (t(1,nm:krm),Ibat_inv(nm:krm,1) ) , xlabel(time_label), ylabel('Iбат, A'); grid;
% axis  ([0.05 2.68 (min(Ibat_inv)-5) (max(Ibat_inv))]);
legend ( 'Ток на батерията, A')
title ('{\bf\it STATUS PV  } \copyright 2003-2012'); % Задава заглавие на чертежното поле

subplot (3,1,2); plot (t(1,nm:krm),Ubat_inv(nm:krm,1)   ) , xlabel(time_label), ylabel('Uбат,V'); grid;
% axis  ([0.05 2.68 (min(Ubat_inv)+40) (max(Ubat_inv)+0.05)]);
% set(gca,'XTick',0:1:24)
legend ( 'Напрежение на батерията, V')
%title ('{\bf\it STATUS PV  } \copyright 2003-2012'); % Задава заглавие на
%чертежното поле

subplot (3,1,3); plot (t(1,nm:krm),abs(Ubat_inv(nm:krm,1).*Ibat_inv(nm:krm,1))   ) , xlabel(time_label), ylabel('Pбат,W'); grid;
% axis  ([0.05 2.68 0 1150]);
% set(gca,'XTick',0:1:24)
legend ( 'Мощност от батерията, W')
%title ('{\bf\it STATUS PV  } \copyright 2003-2012'); % Задава заглавие на
%чертежното поле

% figure(11)
% plot (t(1,nm:krm),abs(Ubat_inv(nm:krm,1).*Ibat_inv(nm:krm,1)) ) , xlabel(time_label), ylabel('P, W'); grid;
% % axis  ([0.05 2.68 0 1150]);
% axis auto;
% legend ( 'Мощност на батерията, W')
% title ('{\bf\it STATUS PV  } \copyright 2003-2012'); % Задава заглавие на чертежното поле


% figure(12)
% plot (t(1,nm:krm), kpd_inv(nm:krm,1)) , xlabel(time_label), ylabel('КПД'); grid;
% % axis  ([0.05 2.68 0 1150]);
% axis auto;
% legend ( 'КПД')
% title ('{\bf\it STATUS PV  } \copyright 2003-2012'); % Задава заглавие на чертежното поле


% figure(13)
% plot (t(1,nm:krm), kpd_charge(nm:krm,1)) , xlabel(time_label), ylabel('КПД зарядн у-во'); grid;
% % axis  ([0.05 2.68 0 1150]);
% axis auto;
% legend ( 'КПД инверторен режим')
% title ('{\bf\it STATUS PV  } \copyright 2003-2012'); % Задава заглавие на чертежното поле

% figure(14)
% subplot (2,1,1); plot (t(1,nm:krm),Ibat_inv(nm:krm,1), t(1,nm:krm),Ibat_BSP(nm:krm,1), t(1,nm:krm), Ibat_PV(nm:krm,1) ) , xlabel(time_label), ylabel('I, A'); grid;
% legend ( 'Ток на батерията от инвертора, A','Ток на батерията Iбат BSP, A', 'Ток на батерията от PV, A' )
% title ('{\bf\it STATUS PV  } \copyright 2003-2012'); % Задава заглавие на чертежното поле
% 
% subplot (2,1,2); plot (t(1,nm:krm),Ubat_inv(nm:krm,1), t(1,nm:krm),Ubat_BSP(nm:krm,1) ) , xlabel(time_label), ylabel('Uбат,V'); grid;
% legend ( 'Напрежение на батерията INV, V', 'Напрежение на батерията BSP, V')
% title ('{\bf\it STATUS PV  } \copyright 2003-2012'); % Задава заглавие на чертежното поле
% 
% figure(15)
% plot (t(1,nm:krm),Pbat_inv(nm:krm,1),'-b',  t(1,nm:krm),Pgen(nm:krm,1), '-m' ,t(1,nm:krm),-Ptow(nm:krm,1), '-r' , t(1,nm:krm), Pbat_PV(nm:krm,1), '-g'   ) , xlabel(time_label), ylabel('P, W'); grid;
% 
% legend ( 'Мощност от/към инвертора Pинв=>бат, W', 'Мощност от дизел генератора Pген, W',  'Мощност на товара Pтов, W', 'Мощност от/към PV, W')
% title ('{\bf\it STATUS PV  } \copyright 2003-2012'); % Задава заглавие на чертежното поле


% figure(16)
% plot (t(1,nm:krm),Pbat_inv(nm:krm,1),'-b',  t(1,nm:krm),Pgen(nm:krm,1), '-m' ,t(1,nm:krm),-Ptow(nm:krm,1), '-r' , t(1,nm:krm), Pbat_PV(nm:krm,1), '-g'   ) , xlabel(time_label), ylabel('P, W'); grid;
% 
% legend ( 'Inverter/charger power Pinv=>bat, W', 'Diesel Generator power P_d_g, W',  'Load power P_l_o_a_d, W', 'PV power P_P_V, W')
% title ('{\bf\it STATUS PV  } \copyright 2003-2013'); % Задава заглавие на чертежното поле

% figure(17)
% plot (t(1,nm:krm),Temp_bat(nm:krm,1),'-b'   ) , xlabel(time_label), ylabel('Температура, градуси'); grid;
% 
% legend ( 'Температура на батерията, градуси')
% title ('{\bf\it STATUS PV  } \copyright 2003-2013'); % Задава заглавие на чертежното поле


% figure(17)
% plot (t(1,nm:krm), matObj.Ibat_BSP(nm:krm,1)) , xlabel(time_label), ylabel('Ibat_BSP'); grid;

figure(18)
plot (t(1,nm:krm), matObj.Ibat_PV(nm:krm,1)) , xlabel(time_label), ylabel('matObj.Ibat_PV'); grid;
%axis([120 150 -5  20])

figure(19)
plot (t(1,nm:krm), Ibat_PV(nm:krm,1)) , xlabel(time_label), ylabel('Ibat_PV'); grid;

% figure(17)
% plot (t,Rvryzka,'-b') , xlabel(time_label), ylabel('R, Ohm'); grid;
% 
% legend ( 'Съпротивление на кабелната връзка, Ohm')
% title ('{\bf\it STATUS PV  } \copyright 2003-2013'); % Задава заглавие на чертежното поле


% figure(18)
% plot (t,Ploss,'-b') , xlabel(time_label), ylabel('R, Ohm'); grid;
% legend ( 'Загуба на мощност в кабелната връзка, W')
% title ('{\bf\it STATUS PV  } \copyright 2003-2013'); % Задава заглавие на чертежното поле

% figure(19)
% plot (t(1,nm:krm),Pgen(nm:krm,1),'-b') , xlabel(time_label), ylabel('P_d_g, W'); grid;
% legend ( 'Diesel Generator power P_d_g, W')
% title ('{\bf\it STATUS PV  } \copyright 2003-2013'); % Задава заглавие на чертежното поле

krm=1*60*24;
figure(20)
subplot (2,1,1)
plot (t(1,nm:krm),-Ptow(nm:krm,1),'-b') , xlabel(time_label), ylabel('Ptow, W'); grid;
legend ( 'Мощност на товара Ptow, W')
title ('{\bf\it STATUS PV  } \copyright 2003-2013'); % Задава заглавие на чертежното поле

subplot (2,1,2)
plot (t(1,nm:krm),Ubat_inv(nm:krm,1),'-b') , xlabel(time_label), ylabel('Ptow, W'); grid;
legend ( 'Напрежение на батерията, V')
title ('{\bf\it STATUS PV  } \copyright 2003-2013'); % Задава заглавие на чертежното поле


