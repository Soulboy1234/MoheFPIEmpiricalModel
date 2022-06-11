function [Sunrise,Sunset,noon] = Fun_zenith_sunrise(lat,doy) %,alt
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% ���� γ��lat���㣩  �߶�alt��m��  �����doy
% ��� �ճ� ���� ���� �ط�ʱ
%
% Li Wenbo
% 2019/05/05
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Debug
% doy=datenum(2019,1,1)-datenum(2019,1,0);
% lat=40.3;
% alt=400*1e3;
% %����wiki���̼����ճ�����
% year=2019;
% lon=116.2;
% [~,month,day]=DOY_MD(year,doy);
% dte=[num2str(year) '-' num2str(month) '-' num2str(day)];
% [SRISE,SSET,NOON]=sunrise(lat,lon,alt,lon./15,dte);
% Sunrise2=str2double(datestr(SRISE,'HH'))+str2double(datestr(SRISE,'MM'))./60;
% Sunset2=str2double(datestr(SSET,'HH'))+str2double(datestr(SSET,'MM'))./60;
% noon2=str2double(datestr(NOON,'HH'))+str2double(datestr(NOON,'MM'))./60;

%% ���춥�Ǽ����ճ�����
%�����춥��
lt=0:0.01:24;
ds=-23.45.*cosd(360.*(doy+10)./365);
zenith=acosd(sind(lat).*sind(ds)+cosd(lat).*cosd(ds).*cosd(15.*(lt-12)));

%ѡȡĿ��Ƕ�
% if alt>400*1e3
%     ionize_alt=100*1e3; % ����߶�
%     RE=6371*1e3+ionize_alt;%m
%     Target_Angle=180-asind(RE./(RE+alt-ionize_alt));
% else
%     RE=6371*1e3;%m
%     Target_Angle=180-asind(RE./(RE+alt));
% end
Target_Angle=100;

%�����ճ�����ʱ��
[~,minloc]=min(zenith);
noon=lt(minloc);
[~,Sunrise_loc]=min(abs(zenith(1:minloc)-Target_Angle));
ltnow=lt(1:minloc);
Sunrise=ltnow(Sunrise_loc);
[~,Sunset_loc]=min(abs(zenith(minloc:end)-Target_Angle));
ltnow=lt(minloc:end);
Sunset=ltnow(Sunset_loc);

end
