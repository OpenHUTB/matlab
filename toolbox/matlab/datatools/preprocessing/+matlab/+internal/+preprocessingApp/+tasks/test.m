numPlots=5;
pixelHeightPerPlot=75;
g=uigridlayout;
t=uitabgroup(g);
tt=uitab(t);
pOut=uipanel(tt,'Scrollable','on','BackgroundColor','blue');
pIn=uipanel(pOut,'BackgroundColor','red','Scrollable','on','Position',[0,1-(5/3),1,(5/3)]);
pIn.BorderType='none';
tl=tiledlayout(pIn,numPlots,1);
tl.Padding='none';
for i=1:numPlots
    ax=nexttile(tl);
    plot(ax,cumsum(randn(50,1)))
end