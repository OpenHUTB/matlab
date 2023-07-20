function SetLimits(x,ha)



    minrow=min(x);
    maxrow=max(x);
    if maxrow==minrow
        upperLim=maxrow+0.1;
        lowerLim=maxrow-0.1;
    elseif maxrow==0
        upperLim=-minrow*0.1;
        lowerLim=minrow*1.1;
    elseif minrow==0
        upperLim=maxrow*1.1;
        lowerLim=-maxrow*0.1;
    elseif maxrow>0
        upperLim=maxrow*1.1;
        if minrow>0
            lowerLim=minrow*0.9;
        else
            lowerLim=minrow*1.1;
        end
    else
        upperLim=maxrow*0.9;
        lowerLim=minrow*1.1;
    end
    ylim(ha,[lowerLim,upperLim]);

end