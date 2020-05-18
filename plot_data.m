%Day|Month|Year|Hour| Minute |Ubat[Vdc]| Ibat(m)[Adc] | Ubatmin [Vdc] | Uin [Vac] |Iin[Aac] | P out [kVA] | P out max [kVA] |  F out [Hz] |  Phase [] | Mode [] |Transfert  |  RME [] | Aux 1 [] | Aux 2 [] | F in [Hz] | P in a [W] | Pout a [W] |  T_elec1 [�C] | BSP U_bat [V] | BSP I_bat [A] | BSP SOC [%] | BSP Tbat [�C] | XCOM MS Pout [kW] | U bat ond [Vrip] | Minigrid [Vdc] | E in tot [dkWh] | E qu [kWh]  |
% 1 | 2   |  3 | 4  |   5    |    6    |     7        |      8        |        9  |     10  |     11      |       12        |     13      |      14   |    15   |    16     |   17    |    18    |   19     |    20     |     21     |    22      |       23      |      24       |      25       |      26     |       27      |        28         |        29        |       30       |        31       |      32     |
%




D= day_data;

A= 1:length(D);

nm=1; %������� ������ �� ��
krm=length(D(:,1))

% ���������� �� ��������� �� � ��� ���������
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
    
    Ubat_inv(k,1) = D(k,19); % ���������� �� ���������, Vdc
    Ibat_inv(k,1) = D(k,20); % ��� �� ���������, Adc
    Uin(k,1) = D(k,7); % ���������� �� ����������, Vac
    Iin(k,1) = D(k,8); % ���������� �� ����������, Vac
    Ubat_BSP (k,1) = D(k,24); % ���������� �� ���������, �������� �� BSP, Vdc
    Ibat_BSP (k,1) = D(k,25);    % ��� �� ���������, ������� �� BSP, Adc
    SOC_BSP(k,1) = D(k,26);    % ��� �� ���������, ������� �� BSP
    Pgen(k,1) = D(k,21); % ������� �� ����������, W
    Ptow(k,1) = D(k,22)*1000; % ������� �� ������, VA
    Pbat_inv(k,1) = Ubat_inv(k,1).*Ibat_inv(k,1); % DC ������� �� ���������, W
    Pbat_BSP(k,1)= Ubat_BSP(k,1).*Ibat_BSP(k,1); % ������� ��/��� ���������, W
    %KPD_inv_DC_AC=  (k,1)
    Temp_bat(k,1)= D(k,23); % ����������� �� ���������, �������
    
    Ibat_PV(k,1) = Ibat_BSP(k,1)-Ibat_inv(k,1); %����� ���� ��
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
    
    %������� �� � ��� ���������
    if Pbat_BSP(k,1)>0
        E_bat_in= E_bat_in + (Pbat_BSP(k,1)/60)/1000; %������� ������� � ���������, kWh
    elseif Pbat_BSP(k,1)<0
        E_bat_out= E_bat_out + (Pbat_BSP(k,1)/60)/1000; %������� �������� �� ���������, kWh
    end
    
    E_gen= E_gen+ ((Uin(k,1)*Iin(k,1))/60)/1000; %������� �������� �� ����������, kWh;
    E_tow= E_tow+ ((Ptow(k,1))/60)/1000; %������� ����������� �� ������, kWh
    
    
    Ttow(k,1)=(60*D(k,4)+D(k,5))/60;
    
    if Uin(k,1) >= 210
        kpd_charge(k,1) = Pbat_inv(k,1)/(Pgen(k,1)-Ptow(k,1));
    elseif Uin(k,1) < 210
        kpd_inv(k,1) = ((Ubat_inv(k,1)*Ibat_inv(k,1))/Ptow(k,1));
    end
    
end

KPD_bat=E_bat_out/E_bat_in



time_period=2% ������� ������ 1-������; 2-������; 3- ���
if time_period==1 % ������
    t=A;
    time_label='t, ���.';
elseif time_period==2 %������
    t=A/60;
    time_label='t, �';
elseif time_period==3 %���
    t= A/(60*24);
    time_label='t, ���';
end

E_pv = abs(E_bat_out)- abs( E_bat_in)
e = E_tow/ E_gen


%������ �� �������� �� ������� � ������ ����
myfile = fullfile('C:\��������\������������\������ ����� �������','battery2019.mat');       
matObj = matfile(myfile,'Writable',true);

  for k = 6:length(D) 
           
       %if D(k,19)< 30
          
       %   matObj.Vbat(k,1)= matObj.Vbat(k-1,1);
       %else    
       %    matObj.Vbat(k,1) = D(k,19);  % ������������ �� ���������
       %end
%       matObj.Ibat(k,1) = D(k,20);  % ��� �� ���������
%       matObj.SOC(k,1) = D(k,26);   % SOC �� ���������   
      %matObj.Ptow(k,1) = -D(k,22)*1000; % ������� �� ������, VA
      matObj.Ibat_BSP(k,1) = Ibat_BSP (k,1); %D(k,25);
      
      
      if Ibat_PV (k,1) < -4 %&& k > 5 
          matObj.Ibat_PV(k,1) = -2; %Ibat_PV(k-1,1);
       else         
          matObj.Ibat_PV(k,1) = Ibat_PV (k,1);
      end
          
  end

  counter=0
  
for i= 6:length(D)-5  % ���� ���� �� ����� ���������� 5 ������ �� ��������
    
    mean_back_value = (Ibat_PV(i-1,1) + Ibat_PV(i-2,1) + Ibat_PV(i-3,1) + Ibat_PV(i-4,1) + Ibat_PV(i-5,1))/5;
    mean_forward_value = (Ibat_PV(i+1,1) + Ibat_PV(i+2,1) + Ibat_PV(i+3,1) + Ibat_PV(i+4,1) + Ibat_PV(i+5,1))/5;
    
   if Ibat_PV(i,1) > 2 && mean_back_value < 0 && mean_forward_value < 0 %Ibat_PV (i,1) > 2.2* abs(mean_back_value) && Ibat_PV (i,1) > 2.2* abs(mean_forward_value)
       matObj.Ibat_PV(i,1) = mean_back_value;
       counter= counter + 1
   end
end

krm= 10*24*60

% figure(1)
% plot (t(1,nm:krm),Ubat_inv(nm:krm,1)   ) , xlabel(time_label), ylabel('U���,V'); grid;
% title ('{\bf\it STATUS PV  } \copyright 2003-2012'); % ������ �������� �� ���������� ����
% %axis([0  0 1.50])

% figure(3)
% subplot (2,1,1);
% plot (t,matObj.Vbat(nm:krm,1)   ) , xlabel(time_label), ylabel('U���,V'); grid;
% title ('{\bf\it STATUS PV  } \copyright 2003-2012'); % ������ �������� �� ���������� ����
% legend ( '���������� �� ���������, V')
% 
% subplot (2,1,2); 
% plot (t,matObj.SOC(nm:krm,1)  ) , xlabel(time_label), ylabel('SOC,%'); grid;
% legend ( 'SOC �� ���������, %')
% %title ('{\bf\it STATUS PV  } \copyright 2003-2012'); % ������ �������� �� ���������� ����

% figure(2)
% plot (Ttow,Ptow,' o','LineWidth',1,'MarkerSize',4)  , xlabel(time_label), ylabel('P���,W'); grid;
% title ('{\bf\it STATUS PV  } \copyright 2003-2012'); % ������ �������� �� ���������� ����

% figure(4)
% subplot (3,1,1); plot (t(1,nm:krm),Ibat_inv(nm:krm,1)), xlabel(time_label), ylabel('I, A'); grid;
% legend ( '��� �� ��������� �� ���������, A' )
% title ('{\bf\it STATUS PV  } \copyright 2003-2012'); % ������ �������� �� ���������� ����
% 
% subplot (3,1,2); plot ( t(1,nm:krm),Ibat_BSP(nm:krm,1)), xlabel(time_label), ylabel('I, A'); grid;
% legend ( '��� �� ��������� I��� BSP, A' )
% 
% 
% subplot (3,1,3); plot ( t(1,nm:krm), Ibat_PV(nm:krm,1) ) , xlabel(time_label), ylabel('I, A'); grid;
% legend ( '��� �� ��������� �� PV, A' )


% figure(8)
% subplot (2,1,1); plot (t,Ubat_inv.*Ibat_inv,   t,Pgen, t,-Ptow , t, Pbat_PV ) , xlabel(time_label), ylabel('P, W'); grid;
% legend ( '������� ��/��� ��������� P���=>���, W', '������� �� ����� ���������� P���, W',  '������� �� ������ P���, W', '������� ��/��� PV, W')
% title ('{\bf\it STATUS PV  } \copyright 2003-2012'); % ������ �������� �� ���������� ����
% 
% subplot (2,1,2); plot (t,Ubat_inv   ) , xlabel(time_label), ylabel('U���,V'); grid;
% legend ( '���������� �� ���������, V')
% %title ('{\bf\it STATUS PV  } \copyright 2003-2012'); % ������ �������� �� ���������� ����


figure(9)
subplot (2,1,1); plot (t(1,nm:krm),Ibat_inv(nm:krm,1) ) , xlabel(time_label), ylabel('I, A'); grid;
legend ( '��� �� ��������� I���, A')
title ('{\bf\it STATUS PV  } \copyright 2003-2012'); % ������ �������� �� ���������� ����

subplot (2,1,2); plot (t(1,nm:krm),Ubat_inv(nm:krm,1)   ) , xlabel(time_label), ylabel('U���,V'); grid;
legend ( '���������� �� ���������, V')
title ('{\bf\it STATUS PV  } \copyright 2003-2012'); % ������ �������� �� ���������� ����

figure(10)
subplot (3,1,1); plot (t(1,nm:krm),Ibat_inv(nm:krm,1) ) , xlabel(time_label), ylabel('I���, A'); grid;
% axis  ([0.05 2.68 (min(Ibat_inv)-5) (max(Ibat_inv))]);
legend ( '��� �� ���������, A')
title ('{\bf\it STATUS PV  } \copyright 2003-2012'); % ������ �������� �� ���������� ����

subplot (3,1,2); plot (t(1,nm:krm),Ubat_inv(nm:krm,1)   ) , xlabel(time_label), ylabel('U���,V'); grid;
% axis  ([0.05 2.68 (min(Ubat_inv)+40) (max(Ubat_inv)+0.05)]);
% set(gca,'XTick',0:1:24)
legend ( '���������� �� ���������, V')
%title ('{\bf\it STATUS PV  } \copyright 2003-2012'); % ������ �������� ��
%���������� ����

subplot (3,1,3); plot (t(1,nm:krm),abs(Ubat_inv(nm:krm,1).*Ibat_inv(nm:krm,1))   ) , xlabel(time_label), ylabel('P���,W'); grid;
% axis  ([0.05 2.68 0 1150]);
% set(gca,'XTick',0:1:24)
legend ( '������� �� ���������, W')
%title ('{\bf\it STATUS PV  } \copyright 2003-2012'); % ������ �������� ��
%���������� ����

% figure(11)
% plot (t(1,nm:krm),abs(Ubat_inv(nm:krm,1).*Ibat_inv(nm:krm,1)) ) , xlabel(time_label), ylabel('P, W'); grid;
% % axis  ([0.05 2.68 0 1150]);
% axis auto;
% legend ( '������� �� ���������, W')
% title ('{\bf\it STATUS PV  } \copyright 2003-2012'); % ������ �������� �� ���������� ����


% figure(12)
% plot (t(1,nm:krm), kpd_inv(nm:krm,1)) , xlabel(time_label), ylabel('���'); grid;
% % axis  ([0.05 2.68 0 1150]);
% axis auto;
% legend ( '���')
% title ('{\bf\it STATUS PV  } \copyright 2003-2012'); % ������ �������� �� ���������� ����


% figure(13)
% plot (t(1,nm:krm), kpd_charge(nm:krm,1)) , xlabel(time_label), ylabel('��� ������ �-��'); grid;
% % axis  ([0.05 2.68 0 1150]);
% axis auto;
% legend ( '��� ���������� �����')
% title ('{\bf\it STATUS PV  } \copyright 2003-2012'); % ������ �������� �� ���������� ����

% figure(14)
% subplot (2,1,1); plot (t(1,nm:krm),Ibat_inv(nm:krm,1), t(1,nm:krm),Ibat_BSP(nm:krm,1), t(1,nm:krm), Ibat_PV(nm:krm,1) ) , xlabel(time_label), ylabel('I, A'); grid;
% legend ( '��� �� ��������� �� ���������, A','��� �� ��������� I��� BSP, A', '��� �� ��������� �� PV, A' )
% title ('{\bf\it STATUS PV  } \copyright 2003-2012'); % ������ �������� �� ���������� ����
% 
% subplot (2,1,2); plot (t(1,nm:krm),Ubat_inv(nm:krm,1), t(1,nm:krm),Ubat_BSP(nm:krm,1) ) , xlabel(time_label), ylabel('U���,V'); grid;
% legend ( '���������� �� ��������� INV, V', '���������� �� ��������� BSP, V')
% title ('{\bf\it STATUS PV  } \copyright 2003-2012'); % ������ �������� �� ���������� ����
% 
% figure(15)
% plot (t(1,nm:krm),Pbat_inv(nm:krm,1),'-b',  t(1,nm:krm),Pgen(nm:krm,1), '-m' ,t(1,nm:krm),-Ptow(nm:krm,1), '-r' , t(1,nm:krm), Pbat_PV(nm:krm,1), '-g'   ) , xlabel(time_label), ylabel('P, W'); grid;
% 
% legend ( '������� ��/��� ��������� P���=>���, W', '������� �� ����� ���������� P���, W',  '������� �� ������ P���, W', '������� ��/��� PV, W')
% title ('{\bf\it STATUS PV  } \copyright 2003-2012'); % ������ �������� �� ���������� ����


% figure(16)
% plot (t(1,nm:krm),Pbat_inv(nm:krm,1),'-b',  t(1,nm:krm),Pgen(nm:krm,1), '-m' ,t(1,nm:krm),-Ptow(nm:krm,1), '-r' , t(1,nm:krm), Pbat_PV(nm:krm,1), '-g'   ) , xlabel(time_label), ylabel('P, W'); grid;
% 
% legend ( 'Inverter/charger power Pinv=>bat, W', 'Diesel Generator power P_d_g, W',  'Load power P_l_o_a_d, W', 'PV power P_P_V, W')
% title ('{\bf\it STATUS PV  } \copyright 2003-2013'); % ������ �������� �� ���������� ����

% figure(17)
% plot (t(1,nm:krm),Temp_bat(nm:krm,1),'-b'   ) , xlabel(time_label), ylabel('�����������, �������'); grid;
% 
% legend ( '����������� �� ���������, �������')
% title ('{\bf\it STATUS PV  } \copyright 2003-2013'); % ������ �������� �� ���������� ����


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
% legend ( '������������� �� ��������� ������, Ohm')
% title ('{\bf\it STATUS PV  } \copyright 2003-2013'); % ������ �������� �� ���������� ����


% figure(18)
% plot (t,Ploss,'-b') , xlabel(time_label), ylabel('R, Ohm'); grid;
% legend ( '������ �� ������� � ��������� ������, W')
% title ('{\bf\it STATUS PV  } \copyright 2003-2013'); % ������ �������� �� ���������� ����

% figure(19)
% plot (t(1,nm:krm),Pgen(nm:krm,1),'-b') , xlabel(time_label), ylabel('P_d_g, W'); grid;
% legend ( 'Diesel Generator power P_d_g, W')
% title ('{\bf\it STATUS PV  } \copyright 2003-2013'); % ������ �������� �� ���������� ����

krm=1*60*24;
figure(20)
subplot (2,1,1)
plot (t(1,nm:krm),-Ptow(nm:krm,1),'-b') , xlabel(time_label), ylabel('Ptow, W'); grid;
legend ( '������� �� ������ Ptow, W')
title ('{\bf\it STATUS PV  } \copyright 2003-2013'); % ������ �������� �� ���������� ����

subplot (2,1,2)
plot (t(1,nm:krm),Ubat_inv(nm:krm,1),'-b') , xlabel(time_label), ylabel('Ptow, W'); grid;
legend ( '���������� �� ���������, V')
title ('{\bf\it STATUS PV  } \copyright 2003-2013'); % ������ �������� �� ���������� ����


