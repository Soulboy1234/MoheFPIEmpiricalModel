%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Mohe 2019年~2021年 FPI风场数据建模
% 返回风场矩阵，（UT，DOY）误差由误差矩阵提供
%
% Li wenbo
% 2020/06/02
% Matlab 2018b
%
% 修改
% [2020/06/08] 加入观测数据计算方差。
% [2020/06/16] 加入误差矩阵计算方差。
% [2020/10/23] 修改数据源 只使用激光器坏掉时段半径法结果
% [2022/02/15] 更新模型，观测数据扩充到 2021年11月10号
% [2022/03/23] 移动版 重新规划输入输出变量
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ZonalWind,dZonalWind,MeridionalWind,dMeridionalWind ...
    ,Sunrise_UT,Sunset_UT,UT,Doy,StationName,StationLon,StationLat] ...
    = MoheFPIWindNURBSModel(input_ut,input_doy,saveFalg)
%% debug
% clear;clc;

%% 路径设置
rootPath = pwd;

%% Station
StationName='MOHE';
StationLon=122.3;
StationLat=53.5;

%% 读取参数
% if nargin < 2
%     load([rootPath filesep 'input.mat'],'input_ut','input_doy')
%     saveFalg = 1;
% end
UT  = input_ut ;
Doy = input_doy;

%% 读取误差
load([rootPath filesep 'dwind.mat'],'Doy_Model_filter','UT_Model_filter' ...
    ,'Meridional_dwind_down_Model_filter','Meridional_dwind_up_Model_filter' ...
    ,'Zonal_dwind_down_Model_filter','Zonal_dwind_up_Model_filter');

%% 计算模型结果
% 子午风
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
        % 使用误差矩阵
        fpdoy = Doy_Model_filter>=Doy(idoy)-2 & Doy_Model_filter<=Doy(idoy)+2;
        fput  = UT_Model_filter>=UT(iut)-1 & UT_Model_filter<=UT(iut)+1;
        dMeridionalWind_UpQuartile(iut,idoy)=nanmean(nanmean(Meridional_dwind_up_Model_filter(fput,fpdoy)));
        dMeridionalWind_DownQuartile(iut,idoy)=nanmean(nanmean(Meridional_dwind_down_Model_filter(fput,fpdoy)));
    end
end


% 纬向风
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
        % 使用误差矩阵
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

