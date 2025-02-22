%% Plots

%% For Singular Plot 

hfig = figure("Name","Picture");  % save the figure handle in a variable
t = out.I_ref.time; 
data = out.I_ref.signals(1).values;

plot(t,data,'k-','LineWidth',1.5,'DisplayName','$\Omega(t)$','Color',"#00FF00");
xlabel('Time $t$ (s)')
ylabel('Current ($mA$)')
fname = 'myfigure';




picturewidth = 20; % set this parameter and keep it forever
hw_ratio = 0.65; % feel free to play with this ratio
set(findall(hfig,'-property','FontSize'),'FontSize',11) % adjust fontsize to your document

set(findall(hfig,'-property','Box'),'Box','off') % optional
set(findall(hfig,'-property','Interpreter'),'Interpreter','latex') 
set(findall(hfig,'-property','TickLabelInterpreter'),'TickLabelInterpreter','latex')
set(hfig,'Units','centimeters','Position',[3 3 picturewidth hw_ratio*picturewidth])
pos = get(hfig,'Position');
set(hfig,'PaperPositionMode','Auto','PaperUnits','centimeters','PaperSize',[pos(3), pos(4)])
%print(hfig,fname,'-dpdf','-painters','-fillpage')
print(hfig,fname,'-dpng','-painters')



%% For Multiple Plots 

numPlots = 3; 
t = out.Power_Output.time; 
data = out.Power_Output;

hfig = figure;
for i = 1:numPlots
    subplot(numPlots,1,i);
    plot(t,data.signals(i).values,'k-','LineWidth',1.5,'DisplayName','$\Omega(t)$','Color',"#00FF00");
    xlabel('time $t$ (s)')
    ylabel('$Voltage$ (mV)')
    fname = 'myfigure';
    
    picturewidth = 20; % set this parameter and keep it forever
    hw_ratio = 0.65; % feel free to play with this ratio
    set(findall(hfig,'-property','FontSize'),'FontSize',11) % adjust fontsize to your document
    
    set(findall(hfig,'-property','Box'),'Box','off') % optional
    set(findall(hfig,'-property','Interpreter'),'Interpreter','latex') 
    set(findall(hfig,'-property','TickLabelInterpreter'),'TickLabelInterpreter','latex')
    set(hfig,'Units','centimeters','Position',[3 3 picturewidth hw_ratio*picturewidth])
    pos = get(hfig,'Position');
    set(hfig,'PaperPositionMode','Auto','PaperUnits','centimeters','PaperSize',[pos(3), pos(4)])
    %print(hfig,fname,'-dpdf','-painters','-fillpage')
    print(hfig,fname,'-dpng','-painters')
end 

