clear
input_doy = 1:365;
input_ut  = 1:24;

[ZonalWind,dZonalWind,MeridionalWind,dMeridionalWind ...
    ,Sunrise_UT,Sunset_UT,UT,Doy,StationName,StationLon,StationLat] ...
    = MoheFPIWindNURBSModel(input_ut,input_doy,1);


%% 画图
figure
subplot(2,2,1)
hold on; box on; grid on;
pcolor(Doy,UT,ZonalWind);
shading flat
title('Mohe FPI Empirical Model - Zonal Wind')
xlabel('Day of Year')
ylabel('Universal Time (h)')
xlim([min(Doy),max(Doy)])
ylim([min(UT),max(UT)])
set(gca,'YTick',[0:2:24])
set(gca,'XTick',[15:30:366])
colorbar;

subplot(2,2,2)
hold on; box on; grid on;
pcolor(Doy,UT,MeridionalWind);
shading flat
title('Mohe FPI Empirical Model - Meridional Wind')
xlabel('Day of Year')
ylabel('Universal Time (h)')
xlim([min(Doy),max(Doy)])
ylim([min(UT),max(UT)])
set(gca,'YTick',[0:2:24])
set(gca,'XTick',[15:30:366])
colorbar;

subplot(2,2,3)
hold on; box on; grid on;
plot_index = 270;
errorbar(UT,ZonalWind(:,plot_index),dZonalWind(:,plot_index));
title(['Mohe FPI Empirical Model - Zonal Wind @ Doy = ' num2str(Doy(plot_index))])
xlabel('Universal Time (h)')
ylabel('Zonal Wind (m/s)')
xlim([min(UT),max(UT)])
set(gca,'YTick',[-300:50:300])
set(gca,'XTick',[0:2:24])


subplot(2,2,4)
hold on; box on; grid on;
errorbar(UT,MeridionalWind(:,plot_index),dMeridionalWind(:,plot_index));
title(['Mohe FPI Empirical Model - Meridional Wind @ Doy = ' num2str(Doy(plot_index))])
xlabel('Universal Time (h)')
ylabel('Meridional Wind (m/s)')
xlim([min(UT),max(UT)])
set(gca,'YTick',[-300:50:300])
set(gca,'XTick',[0:2:24])