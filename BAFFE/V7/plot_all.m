% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % Name        : Danny Toma
% % Date        : February 1, 2019
% % Description : This script plots the results of the BAFFE and the YAAPT
% %               with the keele database as the reference. 
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %


close all

% Load Error results
load yaapt_error_eval.mat
load baffe_error_eval.mat

prompt = 'Save Pictures? \n';
save_input = input(prompt);

%** STUDIO WHITE NOISE ****************************************************
figure(1)
plot(BAFFE_RESULTS.SNRZ,BAFFE_RESULTS.STUDIO_WHITE.FINE.*100,'-o','MarkerSize',7.75,'LineWidth',2)
hold on
plot(YAAPT_RESULTS.SNRZ,YAAPT_RESULTS.STUDIO_WHITE.FINE.*100,'-o','MarkerSize',7.75,'LineWidth',2)
grid on
axis([0 inf 0 5])
set(gca, 'XDir','reverse')
xl=get(gca,'xtick');
xl=num2cell(num2str(xl.'),2);
xl(end)={'\infty'};
set(gca,'xticklabel',xl)
xlabel('SNR [dB]','FontSize',18);
ylabel('Error %','FontSize',18);
title('Fine Error','FontSize',20);
set(gca,'FontSize',18)
set(gca,'FontName','Times')
set(gca,'LineWidth',1)
legend({'BAFFE','YAAPT'},'Location','northwest')

if( save_input == 1)
   print('-dpng','-r600','studio_white_fine.png')
end

figure(2)
plot(BAFFE_RESULTS.SNRZ,BAFFE_RESULTS.STUDIO_WHITE.GROSS5.*100,'-o','MarkerSize',7.75,'LineWidth',2)
hold on
plot(YAAPT_RESULTS.SNRZ,YAAPT_RESULTS.STUDIO_WHITE.GROSS5.*100,'-o','MarkerSize',7.75,'LineWidth',2)
grid on
axis([0 inf 0 20])
set(gca, 'XDir','reverse')
xl=get(gca,'xtick');
xl=num2cell(num2str(xl.'),2);
xl(end)={'\infty'};
set(gca,'xticklabel',xl)
xlabel('SNR [dB]','FontSize',18);
ylabel('Error %','FontSize',18);
title('Gross Error ({\alpha}=0.05)','FontSize',20);
set(gca,'FontSize',18)
set(gca,'FontName','Times')
set(gca,'LineWidth',1)
legend({'BAFFE','YAAPT'},'Location','northwest')

if( save_input == 1)
   print('-dpng','-r600','studio_white_gross_05.png')
end

figure(3)
plot(BAFFE_RESULTS.SNRZ,BAFFE_RESULTS.STUDIO_WHITE.GROSS20.*100,'-o','MarkerSize',7.75,'LineWidth',2)
hold on
plot(YAAPT_RESULTS.SNRZ,YAAPT_RESULTS.STUDIO_WHITE.GROSS20.*100,'-o','MarkerSize',7.75,'LineWidth',2)
grid on
axis([0 inf 0 5])
set(gca, 'XDir','reverse')
xl=get(gca,'xtick');
xl=num2cell(num2str(xl.'),2);
xl(end)={'\infty'};
set(gca,'xticklabel',xl)
xlabel('SNR [dB]','FontSize',18);
ylabel('Error %','FontSize',18);
title('Gross Error ({\alpha}=0.2)','FontSize',20);
set(gca,'FontSize',18)
set(gca,'FontName','Times')
set(gca,'LineWidth',1)
legend({'BAFFE','YAAPT'},'Location','northwest')

if( save_input == 1)
   print('-dpng','-r600','studio_white_gross_20.png')
end

%** TELEPHONE WHITE NOISE *************************************************
figure(4)
plot(BAFFE_RESULTS.SNRZ,BAFFE_RESULTS.TELE_WHITE.FINE.*100,'-o','MarkerSize',7.75,'LineWidth',2)
hold on
plot(YAAPT_RESULTS.SNRZ,YAAPT_RESULTS.TELE_WHITE.FINE.*100,'-o','MarkerSize',7.75,'LineWidth',2)
grid on
axis([0 inf 0 5])
set(gca, 'XDir','reverse')
xl=get(gca,'xtick');
xl=num2cell(num2str(xl.'),2);
xl(end)={'\infty'};
set(gca,'xticklabel',xl)
xlabel('SNR [dB]','FontSize',18);
ylabel('Error %','FontSize',18);
title('Fine Error','FontSize',20);
set(gca,'FontSize',18)
set(gca,'FontName','Times')
set(gca,'LineWidth',1)
legend({'BAFFE','YAAPT'},'Location','northwest')

if( save_input == 1)
   print('-dpng','-r600','tele_white_fine.png')
end

figure(5)
plot(BAFFE_RESULTS.SNRZ,BAFFE_RESULTS.TELE_WHITE.GROSS5.*100,'-o','MarkerSize',7.75,'LineWidth',2)
hold on
plot(YAAPT_RESULTS.SNRZ,YAAPT_RESULTS.TELE_WHITE.GROSS5.*100,'-o','MarkerSize',7.75,'LineWidth',2)
grid on
axis([0 inf 0 30])
set(gca, 'XDir','reverse')
xl=get(gca,'xtick');
xl=num2cell(num2str(xl.'),2);
xl(end)={'\infty'};
set(gca,'xticklabel',xl)
xlabel('SNR [dB]','FontSize',18);
ylabel('Error %','FontSize',18);
title('Gross Error ({\alpha}=0.05)','FontSize',20);
set(gca,'FontSize',18)
set(gca,'FontName','Times')
set(gca,'LineWidth',1)
legend({'BAFFE','YAAPT'},'Location','northwest')

if( save_input == 1)
   print('-dpng','-r600','tele_white_gross_05.png')
end

figure(6)
plot(BAFFE_RESULTS.SNRZ,BAFFE_RESULTS.TELE_WHITE.GROSS20.*100,'-o','MarkerSize',7.75,'LineWidth',2)
hold on
plot(YAAPT_RESULTS.SNRZ,YAAPT_RESULTS.TELE_WHITE.GROSS20.*100,'-o','MarkerSize',7.75,'LineWidth',2)
grid on
axis([0 inf 0 10])
set(gca, 'XDir','reverse')
xl=get(gca,'xtick');
xl=num2cell(num2str(xl.'),2);
xl(end)={'\infty'};
set(gca,'xticklabel',xl)
xlabel('SNR [dB]','FontSize',18);
ylabel('Error %','FontSize',18);
title('Gross Error ({\alpha}=0.2)','FontSize',20);
set(gca,'FontSize',18)
set(gca,'FontName','Times')
set(gca,'LineWidth',1)
legend({'BAFFE','YAAPT'},'Location','northwest')

if( save_input == 1)
   print('-dpng','-r600','tele_white_gross_2.png')
end

%** STUDIO BABBLE NOISE ***************************************************
figure(7)
plot(BAFFE_RESULTS.SNRZ,BAFFE_RESULTS.STUDIO_BABBLE.FINE.*100,'-o','MarkerSize',7.75,'LineWidth',2)
hold on
plot(YAAPT_RESULTS.SNRZ,YAAPT_RESULTS.STUDIO_BABBLE.FINE.*100,'-o','MarkerSize',7.75,'LineWidth',2)
grid on
axis([0 inf 0 10])
set(gca, 'XDir','reverse')
xl=get(gca,'xtick');
xl=num2cell(num2str(xl.'),2);
xl(end)={'\infty'};
set(gca,'xticklabel',xl)
xlabel('SNR [dB]','FontSize',18);
ylabel('Error %','FontSize',18);
title('Fine Error','FontSize',20);
set(gca,'FontSize',18)
set(gca,'FontName','Times')
set(gca,'LineWidth',1)
legend({'BAFFE','YAAPT'},'Location','northwest')

if( save_input == 1)
   print('-dpng','-r600','studio_babble_fine.png')
end

figure(8)
plot(BAFFE_RESULTS.SNRZ,BAFFE_RESULTS.STUDIO_BABBLE.GROSS5.*100,'-o','MarkerSize',7.75,'LineWidth',2)
hold on
plot(YAAPT_RESULTS.SNRZ,YAAPT_RESULTS.STUDIO_BABBLE.GROSS5.*100,'-o','MarkerSize',7.75,'LineWidth',2)
grid on
axis([0 inf 0 40])
set(gca, 'XDir','reverse')
xl=get(gca,'xtick');
xl=num2cell(num2str(xl.'),2);
xl(end)={'\infty'};
set(gca,'xticklabel',xl)
xlabel('SNR [dB]','FontSize',18);
ylabel('Error %','FontSize',18);
title('Gross Error ({\alpha}=0.05)','FontSize',20);
set(gca,'FontSize',18)
set(gca,'FontName','Times')
set(gca,'LineWidth',1)
legend({'BAFFE','YAAPT'},'Location','northwest')

if( save_input == 1)
   print('-dpng','-r600','studio_babble_gross_05.png')
end

figure(9)
plot(BAFFE_RESULTS.SNRZ,BAFFE_RESULTS.STUDIO_BABBLE.GROSS20.*100,'-o','MarkerSize',7.75,'LineWidth',2)
hold on
plot(YAAPT_RESULTS.SNRZ,YAAPT_RESULTS.STUDIO_BABBLE.GROSS20.*100,'-o','MarkerSize',7.75,'LineWidth',2)
grid on
axis([0 inf 0 20])
set(gca, 'XDir','reverse')
xl=get(gca,'xtick');
xl=num2cell(num2str(xl.'),2);
xl(end)={'\infty'};
set(gca,'xticklabel',xl)
xlabel('SNR [dB]','FontSize',18);
ylabel('Error %','FontSize',18);
title('Gross Error ({\alpha}=0.2)','FontSize',20);
set(gca,'FontSize',18)
set(gca,'FontName','Times')
set(gca,'LineWidth',1)
legend({'BAFFE','YAAPT'},'Location','northwest')

if( save_input == 1)
   print('-dpng','-r600','studio_babble_gross_20.png')
end

%** TELEPHONE BABBLE NOISE ************************************************
figure(10)
plot(BAFFE_RESULTS.SNRZ,BAFFE_RESULTS.TELE_BABBLE.FINE.*100,'-o','MarkerSize',7.75,'LineWidth',2)
hold on
plot(YAAPT_RESULTS.SNRZ,YAAPT_RESULTS.TELE_BABBLE.FINE.*100,'-o','MarkerSize',7.75,'LineWidth',2)
grid on
axis([0 inf 0 30])
set(gca, 'XDir','reverse')
xl=get(gca,'xtick');
xl=num2cell(num2str(xl.'),2);
xl(end)={'\infty'};
set(gca,'xticklabel',xl)
xlabel('SNR [dB]','FontSize',18);
ylabel('Error %','FontSize',18);
title('Fine Error','FontSize',20);
set(gca,'FontSize',18)
set(gca,'FontName','Times')
set(gca,'LineWidth',1)
legend({'BAFFE','YAAPT'},'Location','northwest')

if( save_input == 1)
   print('-dpng','-r600','tele_babble_fine.png')
end

figure(11)
plot(BAFFE_RESULTS.SNRZ,BAFFE_RESULTS.TELE_BABBLE.GROSS5.*100,'-o','MarkerSize',7.75,'LineWidth',2)
hold on
plot(YAAPT_RESULTS.SNRZ,YAAPT_RESULTS.TELE_BABBLE.GROSS5.*100,'-o','MarkerSize',7.75,'LineWidth',2)
grid on
axis([0 inf 0 70])
set(gca, 'XDir','reverse')
xl=get(gca,'xtick');
xl=num2cell(num2str(xl.'),2);
xl(end)={'\infty'};
set(gca,'xticklabel',xl)
xlabel('SNR [dB]','FontSize',18);
ylabel('Error %','FontSize',18);
title('Gross Error ({\alpha}=0.05)','FontSize',20);
set(gca,'FontSize',18)
set(gca,'FontName','Times')
set(gca,'LineWidth',1)
legend({'BAFFE','YAAPT'},'Location','northwest')

if( save_input == 1)
   print('-dpng','-r600','tele_babble_gross_05.png')
end

figure(12)
plot(BAFFE_RESULTS.SNRZ,BAFFE_RESULTS.TELE_BABBLE.GROSS20.*100,'-o','MarkerSize',7.75,'LineWidth',2)
hold on
plot(YAAPT_RESULTS.SNRZ,YAAPT_RESULTS.TELE_BABBLE.GROSS20.*100,'-o','MarkerSize',7.75,'LineWidth',2)
grid on
axis([0 inf 0 50])
set(gca, 'XDir','reverse')
xl=get(gca,'xtick');
xl=num2cell(num2str(xl.'),2);
xl(end)={'\infty'};
set(gca,'xticklabel',xl)
xlabel('SNR [dB]','FontSize',18);
ylabel('Error %','FontSize',18);
title('Gross Error ({\alpha}=0.2)','FontSize',20);
set(gca,'FontSize',18)
set(gca,'FontName','Times')
set(gca,'LineWidth',1)
legend({'BAFFE','YAAPT'},'Location','northwest')

if( save_input == 1)
   print('-dpng','-r600','tele_babble_gross_20.png')
end

