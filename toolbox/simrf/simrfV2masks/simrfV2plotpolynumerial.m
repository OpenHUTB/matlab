function simrfV2plotpolynumerial(block,dialog)

    if strcmpi(get_param(bdroot(block),'BlockDiagramType'),'library')
        return;
    end
    if dialog.hasUnappliedChanges
        blkName=regexprep(block,'\n','');
        error(message('simrf:simrfV2errors:ApplyButton',blkName));
    end

    type=get_param(block,'Source_linear_gain');
    switch type
    case 'AM/AM-AM/PM table'

    case 'Polynomial coefficients'
    otherwise

        obj=calcPolyAndCharacteristics(block);
    end
    obj.LinearGainDB=str2double(dialog.getWidgetValue('linear_gain'));
    actionData=[];
    visualise(obj,actionData,type)

    return
end


function visualise(obj,~,type)

    if strcmpi(type,'AM/AM-AM/PM table')


































































    else

        figureID=matlab.lang.makeValidName(...
        [get_param(gcbh,'MaskType'),'_',get_param(gcbh,'Handle')...
        ],'ReplacementStyle','hex');

        OuterPosition=visualFigPlacement(1,4);
        hfig=findall(0,'Type','Figure','Tag',figureID);

        top_source=get_param(bdroot(gcs),'Object');

        if top_source.hasCallback('PreClose',figureID)
            top_source.removeCallback('PreClose',figureID);
        end

        if~isempty(hfig)&&ishghandle(hfig)
            delete(hfig)
        end

        hFig=figure('HandleVisibility','callback','Tag',figureID,...
        'OuterPosition',OuterPosition);
        hFig.Name=get_param(gcbh,'Name');
        hFig.NumberTitle='off';

        hAxes=axes('Parent',hFig);

        if obj.c3~=0

            line(hAxes,'XData',obj.pin,'YData',obj.poutActSat,...
            'LineStyle','-','Color','blue','LineWidth',1.6,'Tag','Poly')
            line(hAxes,'XData',obj.pin,'YData',obj.poutIdealSat,...
            'LineStyle',':','Tag','Ideal')
            line(hAxes,'XData',obj.pin,'YData',obj.poutLinear,...
            'LineStyle','-.','Color','red','Tag','Linear')
            line(hAxes,'XData',obj.pin,'YData',obj.pout3rdOrd,...
            'LineStyle','--','Color','#ED8120','Tag','3rdOrd')

            pinMin=floor(obj.Pi1dB/10)*10-10;
            pinMax=ceil((obj.IIP3*1.01)/10)*10;
            if pinMax>max(obj.pin)
                pinMax=max(obj.pin);
            end
            if strcmpi(type,'Data Source')
                poutMin=pinMin;
            else
                poutMin=pinMin+obj.LinearGainDB;
            end
            idx=find(obj.poutIdealSat==max(obj.poutIdealSat));
            opsat_dbm=obj.poutIdealSat(idx(1));
            ipsat_dbm=obj.pin(idx(1));
            iip3_dbm=obj.IIP3;
            oip3_dbm=obj.IIP3+obj.G;
            ip1dbm=obj.Pi1dB;
            op1dbm=obj.Po1dB;
            line(hAxes,'Xdata',[ip1dbm,ip1dbm],...
            'YData',[obj.pin(1),op1dbm],'Color','#CDCDCD','Tag','IP1dB')
            text(hAxes,ip1dbm,poutMin+2,...
            ['IP1dB = ',num2str(ip1dbm,3),'\rightarrow'],...
            'HorizontalAlignment','right')
            if~obj.noSat
                line(hAxes,'Xdata',[ipsat_dbm,ipsat_dbm],...
                'YData',[obj.pin(1),opsat_dbm],'Color','#CDCDCD','Tag','IPsat')
                text(hAxes,ipsat_dbm,poutMin+4,...
                ['IPsat = ',num2str(ipsat_dbm,3),'\rightarrow'],...
                'HorizontalAlignment','right')
                line(hAxes,'Xdata',[pinMin,ipsat_dbm],...
                'YData',[opsat_dbm,opsat_dbm],'Color','#CDCDCD','Tag','OPsat')
                text(hAxes,pinMin+1,opsat_dbm,...
                ['OPsat = ',num2str(opsat_dbm,3),'\downarrow'],...
                'VerticalAlignment','bottom')
                text(hAxes,pinMax,obj.PoutIdealSatLimit,['Ideal Psat = '...
                ,num2str(obj.PoutIdealSatLimit,3),' \uparrow'],...
                'HorizontalAlignment','right','VerticalAlignment','top');
                text(hAxes,pinMax,obj.PoutActSatLimit,['Actual Psat = '...
                ,num2str(obj.PoutActSatLimit,3),' \downarrow'],...
                'HorizontalAlignment','right','VerticalAlignment','bottom');
            end
            line(hAxes,'Xdata',[iip3_dbm,iip3_dbm],...
            'YData',[obj.pin(1),oip3_dbm],'Color','#CDCDCD','Tag','IIP3')
            text(hAxes,iip3_dbm,poutMin+6,...
            ['IIP3 = ',num2str(iip3_dbm,3),'\rightarrow'],...
            'HorizontalAlignment','right')
            line(hAxes,'Xdata',[pinMin,ip1dbm],...
            'YData',[op1dbm,op1dbm],'Color','#CDCDCD','Tag','OP1dB')
            text(hAxes,pinMin+1,op1dbm,...
            ['OP1dB = ',num2str(op1dbm,3),'\uparrow'],...
            'VerticalAlignment','top')
            line(hAxes,'Xdata',[pinMin,iip3_dbm],...
            'YData',[oip3_dbm,oip3_dbm],'Color','#CDCDCD','Tag','OIP3')
            text(hAxes,pinMin+1,oip3_dbm,...
            ['OIP3 = ',num2str(oip3_dbm,3),'\downarrow'],...
            'VerticalAlignment','bottom')

            line(hAxes,[obj.Pi1dB,obj.Pi1dB],[obj.Po1dB,obj.Po1dB+1],'color','k','Tag','1dBComp');
            text(hAxes,obj.Pi1dB,obj.Po1dB+0.5,'1dB \rightarrow','HorizontalAlignment','right');

            legend(hAxes,{'Amplifier C-E','Amplifier Ideal','Linear Gain','3rd Harmonic'},...
            'Location','north')
            hAxes.XLim=[pinMin,pinMax];
            hAxes.YLim=[poutMin,ceil((oip3_dbm*1.01)/10)*10];
            text(hAxes,iip3_dbm,iip3_dbm+obj.G,...
            '\leftarrow IP3','HorizontalAlignment','left')
        else
            line(hAxes,'XData',obj.pin,'YData',obj.poutActSat,...
            'LineStyle','-','Color','blue','LineWidth',1.6)
            line(hAxes,'XData',obj.pin,'YData',obj.poutLinear,...
            'LineStyle','-.','Color','red')
            legend(hAxes,{'Cubic term is zero','Linear Gain'},'Location','southeast')
        end
        xlabel(hAxes,'P_i_n (dBm)')
        ylabel(hAxes,'P_o_u_t (dBm)')
        title(hAxes,'Amplifier')
    end
end















