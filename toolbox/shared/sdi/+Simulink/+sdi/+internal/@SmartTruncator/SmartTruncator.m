classdef SmartTruncator<handle










































    properties
        PathFontFamily;
        PathFontSize;
        PathOuterMargin;
        PathBold;
        PathItalic;
        PathTableEntryWidth;
    end

    properties(Hidden=true,Access=private)
        HFig;
        HAxes;
        HText;
    end

    methods
        function obj=SmartTruncator()



            obj.HFig=figure('Visible','off','HandleVisibility','off');
            obj.HAxes=axes('Parent',obj.HFig);

            obj.HText=text('Visible','off','HandleVisibility','off',...
            'Margin',0.1,'Units','pixels',...
            'Parent',obj.HAxes);
            obj.PathBold=false;
            obj.PathItalic=false;
        end

        function result=evaluate(obj,str)

            limitExceeded=obj.checkWidth(str);
            if(limitExceeded==0)

                result=str;
                return;
            end



            parts=regexp(str,'/','split');


            lp=length(parts);



            if(lp<=2)

                result=str;
                return;
            end

            endPart=['/',parts{end}];
            prev_result=[parts{1},'/','...',endPart];


            for iparts=(lp-1):-1:2
                result=prev_result;

                tempPath=[parts{1},'/','...','/',parts{iparts},endPart];
                limitExceeded=obj.checkWidth(tempPath);
                if(limitExceeded==1)
                    break;
                end
                endPart=['/',parts{iparts},endPart];%#ok<*AGROW>
                prev_result=tempPath;
            end
        end


        function delete(obj)
            close(obj.HFig);
            clear obj.HFig obj.HAxes obj.HText obj.Style;
        end
    end

    methods(Access=private)
        function limitExceeded=checkWidth(obj,str)

            font=obj.PathFontFamily;
            fontsize=obj.PathFontSize;

            p=strfind(fontsize,'pt');
            fontsize(p:end)='';

            set(obj.HText,'String',str,'FontName',font,'FontSize',...
            str2double(fontsize),'FontWeight','normal','FontAngle','normal');

            if obj.PathBold
                set(obj.HText,'FontWeight','bold');
            end

            if obj.PathItalic
                set(obj.HText,'FontAngle','italic');
            end

            textObjExtent=get(obj.HText,'Extent');
            extent=textObjExtent(3);

            if~isempty(obj.PathOuterMargin)
                pad=obj.PathOuterMargin;
                p=strfind(pad,'px');
                pad(p:end)='';
                extent=extent+str2double(pad);
            end


            limitExceeded=(extent>str2double(obj.PathTableEntryWidth));
        end
    end

end

