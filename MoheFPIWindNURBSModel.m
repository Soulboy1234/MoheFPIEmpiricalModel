%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Mohe 2019��~2021�� FPI�糡���ݽ�ģ
% ���ط糡���󣬣�UT��DOY��������������ṩ
%
% Li wenbo
% 2020/06/02
% Matlab 2018b
%
% �޸�
% [2020/06/08] ����۲����ݼ��㷽�
% [2020/06/16] ������������㷽�
% [2020/10/23] �޸�����Դ ֻʹ�ü���������ʱ�ΰ뾶�����
% [2022/02/15] ����ģ�ͣ��۲��������䵽 2021��11��10��
% [2022/03/23] �ƶ��� ���¹滮�����������
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ZonalWind,dZonalWind,MeridionalWind,dMeridionalWind ...
    ,Sunrise_UT,Sunset_UT,UT,Doy,StationName,StationLon,StationLat] ...
    = MoheFPIWindNURBSModel(input_ut,input_doy,saveFalg)
%% debug
% clear;clc;

%% ·������
rootPath = pwd;

%% Station
StationName='MOHE';
StationLon=122.3;
StationLat=53.5;

%% ��ȡ����
if nargin < 2
    load([rootPath filesep 'input.mat'],'input_ut','input_doy')
    saveFalg = 1;
end
UT  = input_ut ;
Doy = input_doy;

%% ��ȡ���
load([rootPath filesep 'dwind.mat'],'Doy_Model_filter','UT_Model_filter' ...
    ,'Meridional_dwind_down_Model_filter','Meridional_dwind_up_Model_filter' ...
    ,'Zonal_dwind_down_Model_filter','Zonal_dwind_up_Model_filter');

%% ����ģ�ͽ��
% �����
load([rootPath filesep 'MeridionalModel.mat'],'buf','nodeDoy','nodeUT','orderDoy','orderUT','periodDoy','periodUT');
MeridionalWind=zeros(length(UT),length(Doy));
dMeridionalWind_UpQuartile=nan(length(UT),length(Doy));
dMeridionalWind_DownQuartile=nan(length(UT),length(Doy));
Sunrise_LT=nan(size(Doy));
Sunset_LT=nan(size(Doy));
Sunrise_UT=nan(size(Doy));
Sunset_UT=nan(size(Doy));
for idoy=1:length(Doy)
    [Sunrise_LT(idoy),Sunset_LT(idoy),~]=Fun_zenith_sunrise(StationLat,Doy(idoy));
    Sunrise_UT(idoy)=Sunrise_LT(idoy)-StationLon./15;
    Sunset_UT(idoy)=Sunset_LT(idoy)-StationLon./15;
    if Sunrise_UT(idoy) < Sunset_UT(idoy)
        Sunrise_UT(idoy)=Sunrise_UT(idoy)+24;
    end

    for iut=1:length(UT)
        if UT(iut)<Sunset_UT(idoy) || UT(iut)>Sunrise_UT(idoy)
            MeridionalWind(iut,idoy)=nan;
            continue;
        end
        inum=0;
        for iDoy=1:length(nodeDoy)
            for iUT=1:length(nodeUT)
                NiLT=Fun_bspl4(iUT,UT(iut),nodeUT,periodUT,orderUT);
                MiDoy=Fun_bspl4(iDoy,Doy(idoy),nodeDoy,periodDoy,orderDoy);
                inum=inum+1;
                MeridionalWind(iut,idoy)=MeridionalWind(iut,idoy)...
                    +buf(inum).*NiLT.*MiDoy;
            end
        end
        % ʹ��������
        fpdoy = Doy_Model_filter>=Doy(idoy)-2 & Doy_Model_filter<=Doy(idoy)+2;
        fput  = UT_Model_filter>=UT(iut)-1 & UT_Model_filter<=UT(iut)+1;
        dMeridionalWind_UpQuartile(iut,idoy)=nanmean(nanmean(Meridional_dwind_up_Model_filter(fput,fpdoy)));
        dMeridionalWind_DownQuartile(iut,idoy)=nanmean(nanmean(Meridional_dwind_down_Model_filter(fput,fpdoy)));
    end
end


% γ���
load([rootPath filesep 'ZonalModel.mat'],'buf','nodeDoy','nodeUT','orderDoy','orderUT','periodDoy','periodUT')
ZonalWind=zeros(length(UT),length(Doy));
dZonalWind_UpQuartile=nan(length(UT),length(Doy));
dZonalWind_DownQuartile=nan(length(UT),length(Doy));
Sunrise_LT=nan(size(Doy));
Sunset_LT=nan(size(Doy));
Sunrise_UT=nan(size(Doy));
Sunset_UT=nan(size(Doy));
for idoy=1:length(Doy)
    [Sunrise_LT(idoy),Sunset_LT(idoy),~]=Fun_zenith_sunrise(StationLat,Doy(idoy));
    Sunrise_UT(idoy)=Sunrise_LT(idoy)-StationLon./15;
    Sunset_UT(idoy)=Sunset_LT(idoy)-StationLon./15;
    if Sunrise_UT(idoy) < Sunset_UT(idoy)
        Sunrise_UT(idoy)=Sunrise_UT(idoy)+24;
    end

    for iut=1:length(UT)
        if UT(iut)<Sunset_UT(idoy) || UT(iut)>Sunrise_UT(idoy)
            ZonalWind(iut,idoy)=nan;
            continue;
        end
        inum=0;
        for iDoy=1:length(nodeDoy)
            for iUT=1:length(nodeUT)
                NiLT=Fun_bspl4(iUT,UT(iut),nodeUT,periodUT,orderUT);
                MiDoy=Fun_bspl4(iDoy,Doy(idoy),nodeDoy,periodDoy,orderDoy);
                inum=inum+1;
                ZonalWind(iut,idoy)=ZonalWind(iut,idoy)...
                    +buf(inum).*NiLT.*MiDoy;
            end
        end
        % ʹ��������
        fpdoy = Doy_Model_filter>=Doy(idoy)-2 & Doy_Model_filter<=Doy(idoy)+2;
        fput  = UT_Model_filter>=UT(iut)-1 & UT_Model_filter<=UT(iut)+1;
        dZonalWind_UpQuartile(iut,idoy)=nanmean(nanmean(Zonal_dwind_up_Model_filter(fput,fpdoy)));
        dZonalWind_DownQuartile(iut,idoy)=nanmean(nanmean(Zonal_dwind_down_Model_filter(fput,fpdoy)));
    end
end

dZonalWind = (dZonalWind_UpQuartile - dZonalWind_DownQuartile)./2;
dMeridionalWind = (dMeridionalWind_UpQuartile - dMeridionalWind_DownQuartile)./2;
% save(['result.mat'],'ZonalWind','dZonalWind_UpQuartile','dZonalWind_DownQuartile' ...
%     ,'MeridionalWind','dMeridionalWind_UpQuartile','dMeridionalWind_DownQuartile'...
%     ,'Sunrise_UT','Sunset_UT','UT','Doy','dZonalWind','dMeridionalWind')
if saveFalg == 1
    save([rootPath filesep 'result.mat'],'ZonalWind','dZonalWind' ...
        ,'MeridionalWind','dMeridionalWind'...
        ,'Sunrise_UT','Sunset_UT','UT','Doy' ...
        ,'StationName','StationLon','StationLat')
end
end

