function[height,width]=getFigureSize()

    fig=gcf;
    figPos=fig.Position;
    width=sprintf('"%0.0fpx"',figPos(3));
    height=sprintf('"%0.0fpx"',figPos(4));
end
