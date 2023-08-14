classdef FigureScreenReaderManager






    methods(Static)

        function updateFigureAriaLabel(f)




            import matlab.graphics.internal.FigureScreenReaderManager;




            if~matlab.graphics.internal.FigureScreenReaderManager.isSupportedFigure(f)
                return
            end

            if~isprop(f,'AriaLabelInMOL_')
                pAriaLabelInMOL_=addprop(f,'AriaLabelInMOL_');
                pAriaLabelInMOL_.Transient=true;
                pAriaLabelInMOL_.Hidden=true;
            end
            if~isprop(f,'AriaLiveInMOL_')
                pAriaLiveInMOL_=addprop(f,'AriaLiveInMOL_');
                pAriaLiveInMOL_.Transient=true;
                pAriaLiveInMOL_.Hidden=true;
            end

            ariaLabel=FigureScreenReaderManager.figureDescription(f);

            if~isempty(f.CurrentAxes)
                ariaLabel=ariaLabel+" "+FigureScreenReaderManager.gcaDescription(f.CurrentAxes);
            end


            ariaLabelChars=char(ariaLabel);
            if~isequal(f.AriaLabelInMOL_,ariaLabel)

                FigureScreenReaderManager.updateAriaLabel(f,ariaLabel);
                f.AriaLabelInMOL_=ariaLabel;
            end

            if isequal(f.AriaLiveInMOL_,ariaLabel)






                if numel(ariaLabelChars)>0&&ariaLabelChars(end)~='.'
                    ariaLabelChars=[ariaLabelChars,'.'];
                end
            end
            f.AriaLiveInMOL_=string(ariaLabelChars);
            matlab.graphics.internal.FigureScreenReaderManager.updateFigureAriaLiveTextContent(f,ariaLabelChars);

        end

        function updateFigureAriaLiveTextContent(f,textContent)
            import matlab.graphics.internal.FigureScreenReaderManager;

            if~matlab.graphics.internal.FigureScreenReaderManager.isSupportedFigure(f)
                return
            end

            if~isprop(f,'AriaLiveTextContent')
                pAriaLiveTextContent=addprop(f,'AriaLiveTextContent');
                pAriaLiveTextContent.Transient=true;
                pAriaLiveTextContent.Hidden=true;
            end



            f.AriaLiveTextContent=textContent;

            FigureScreenReaderManager.updateAriaLiveTextContent(f,textContent);

        end

        function altTextJSON=updateFigureAltTextForDoc(f)



            import matlab.graphics.internal.FigureScreenReaderManager;



            try
                allAxes=getVisibleAndImageAxes(f);
                if~FigureScreenReaderManager.validateFigureContent(f,allAxes)
                    altTextJSON=mls.internal.toJSON(struct('String',"MATLAB figure",'Tex',[],'LaTex',[]));
                    return
                end
                altText=FigureScreenReaderManager.figureDescriptionForDoc(f,allAxes);
                [axesDescription,texStrings,latexStrings]=...
                FigureScreenReaderManager.axesDescriptionForDoc(allAxes);
                altText=altText+axesDescription;
                altText=altText+FigureScreenReaderManager.chartDescriptionForDoc(f);
                altText=removeInvalidXMLChars(altText);
                altTextJSON=mls.internal.toJSON(struct('String',altText,'Tex',texStrings,'LaTex',latexStrings));
            catch e %#ok<NASGU>


                altTextJSON=mls.internal.toJSON(struct('String',"MATLAB figure",'Tex',[],'LaTex',[]));
            end
        end

        function state=isSupportedFigure(f)



            import matlab.graphics.internal.FigureScreenReaderManager;
            state=isvalid(f)&&f.BeingDeleted=="off"&&f.Visible=="on"&&...
            (FigureScreenReaderManager.isTesting||isWebFigureType(f,'EmbeddedMorphableFigure'));
        end
    end

    methods(Static,Hidden)
        function isTestingValue=isTesting(state)
            persistent testingState;
            if nargin>=1
                testingState=state;
            end
            isTestingValue=~isempty(testingState)&&testingState;
        end
    end

    methods(Static,Access=private)

        function figureDescription=figureDescription(f)








            import matlab.graphics.internal.FigureScreenReaderManager;
            currentAxes=f.CurrentAxes;
            figureChildren=FigureScreenReaderManager.getAnnouncedNonAxesFigureDescendants(f);

            if strlength(deblank(f.Name))==0
                if f.IntegerHandle
                    if isempty(currentAxes)


                        if isempty(figureChildren)

                            figureDescription=getString(message('MATLAB:graphics:figurescreenreader:FigureDescriptionNumNoChildren',f.Number));
                        else

                            figureDescription=getString(message('MATLAB:graphics:figurescreenreader:FigureDescriptionNumWithChildren',...
                            f.Number,join(unique(string(get(figureChildren,{'Type'})),'stable'),', ')));
                        end
                    else





                        allAxes=findobj(f.Children,'-isa','matlab.graphics.axis.AbstractAxes');
                        if length(allAxes)>=2

                            figureDescription=getString(message('MATLAB:graphics:figurescreenreader:FigureDescriptionNumWithMultipleAxes',f.Number,length(allAxes)));
                        else

                            figureDescription=getString(message('MATLAB:graphics:figurescreenreader:FigureDescriptionNumWithSingleAxes',f.Number));
                        end
                    end
                else
                    if isempty(currentAxes)


                        if isempty(figureChildren)

                            figureDescription=getString(message('MATLAB:graphics:figurescreenreader:FigureDescriptionNoNumNoChildren'));
                        else

                            figureDescription=getString(message('MATLAB:graphics:figurescreenreader:FigureDescriptionNoNumWithChildren',...
                            join(unique(string(get(figureChildren,{'Type'})),'stable'),', ')));
                        end
                    else




                        allAxes=findobj(f.Children,'-isa','matlab.graphics.axis.AbstractAxes');
                        if length(allAxes)>=2

                            figureDescription=getString(message('MATLAB:graphics:figurescreenreader:FigureDescriptionNoNumWithMultipleAxes',length(allAxes)));
                        else

                            figureDescription=getString(message('MATLAB:graphics:figurescreenreader:FigureDescriptionNoNumWithSingleAxes'));
                        end
                    end
                end

            else
                if isempty(currentAxes)


                    if isempty(figureChildren)

                        figureDescription=getString(message('MATLAB:graphics:figurescreenreader:FigureDescriptionNamedNoChildren',f.Name));
                    else

                        figureDescription=getString(message('MATLAB:graphics:figurescreenreader:FigureDescriptionNamedWithChildren',...
                        f.Name,join(unique(string(get(figureChildren,{'Type'})),'stable'),', ')));
                    end
                else




                    allAxes=findobj(f.Children,'-isa','matlab.graphics.axis.AbstractAxes');
                    if length(allAxes)>=2

                        figureDescription=getString(message('MATLAB:graphics:figurescreenreader:FigureDescriptionNamedWithMultipleAxes',f.Name,length(allAxes)));
                    else

                        figureDescription=getString(message('MATLAB:graphics:figurescreenreader:FigureDescriptionNamedWithSingleAxes',f.Name));
                    end
                end
            end
            figureDescription=string(figureDescription);

        end

        function figureDescription=figureDescriptionForDoc(f,allAxes)




            import matlab.graphics.internal.FigureScreenReaderManager;
            lc_en=matlab.internal.i18n.locale('en');

            nonAxesChildren=FigureScreenReaderManager.getAnnouncedNonAxesFigureDescendants(f,"matlab.graphics.axis.AbstractAxes");
            if strlength(deblank(f.Name))==0
                if isempty(nonAxesChildren)
                    if numel(allAxes)==1
                        figureDescription=getString(message('MATLAB:graphics:figurescreenreader:UnnamedFigureSingleAxes'),lc_en);
                    elseif numel(allAxes)==0
                        figureDescription="";
                    else
                        figureDescription=getString(message('MATLAB:graphics:figurescreenreader:UnnamedFigureMultipleAxes',numel(allAxes)),lc_en);
                    end
                elseif numel(nonAxesChildren)==1
                    if numel(allAxes)==1
                        figureDescription=getString(message('MATLAB:graphics:figurescreenreader:UnnamedFigureSingleNonAxesChildrenSingleAxes',...
                        nonAxesChildren.Type),lc_en);
                    elseif numel(allAxes)==0
                        figureDescription=getString(message('MATLAB:graphics:figurescreenreader:UnnamedFigureNoAxesWithOneOtherChild',...
                        nonAxesChildren.Type),lc_en);
                    else
                        figureDescription=getString(message('MATLAB:graphics:figurescreenreader:UnnamedFigureSingleNonAxesChildMultipleAxes',...
                        numel(allAxes),nonAxesChildren.Type),lc_en);
                    end
                else
                    if numel(allAxes)==1
                        figureDescription=getString(message('MATLAB:graphics:figurescreenreader:UnnamedFigureNonAxesChildrenSingleAxes',...
                        join(unique(string(get(nonAxesChildren,{'Type'})),'stable'),', ')),lc_en);
                    elseif numel(allAxes)==0
                        figureDescription=getString(message('MATLAB:graphics:figurescreenreader:UnnamedFigureNoAxesWithOtherChildren',...
                        join(unique(string(get(nonAxesChildren,{'Type'})),'stable'),', ')),lc_en);
                    else
                        figureDescription=getString(message('MATLAB:graphics:figurescreenreader:UnnamedFigureNonAxesChildrenMultipleAxes',...
                        numel(allAxes),join(unique(string(get(nonAxesChildren,{'Type'})),'stable'),', ')),lc_en);
                    end
                end
            else
                if isempty(nonAxesChildren)
                    if numel(allAxes)==1
                        figureDescription=getString(message('MATLAB:graphics:figurescreenreader:NamedFigureSingleAxes',f.Name),lc_en);
                    elseif numel(allAxes)==0
                        figureDescription="";
                    else
                        figureDescription=getString(message('MATLAB:graphics:figurescreenreader:NamedFigureMultipleAxes',f.Name,numel(allAxes)),lc_en);
                    end
                elseif numel(nonAxesChildren)==1
                    if numel(allAxes)==1
                        figureDescription=getString(message('MATLAB:graphics:figurescreenreader:NamedFigureSingleNonAxesChildSingleAxes',...
                        f.Name,nonAxesChildren.Type),lc_en);
                    elseif numel(allAxes)==0
                        figureDescription=getString(message('MATLAB:graphics:figurescreenreader:NamedFigureNoAxesWithOneOtherChild',...
                        f.Name,nonAxesChildren.Type),lc_en);
                    else
                        figureDescription=getString(message('MATLAB:graphics:figurescreenreader:NamedFigureSingleNonAxesChildMultipleAxes',...
                        f.Name,numel(allAxes),nonAxesChildren.Type),lc_en);
                    end
                else
                    if numel(allAxes)==1
                        figureDescription=getString(message('MATLAB:graphics:figurescreenreader:NamedFigureNonAxesChildrenSingleAxes',...
                        f.Name,join(unique(string(get(nonAxesChildren,{'Type'})),'stable'),', ')),lc_en);
                    elseif numel(allAxes)==0
                        figureDescription=getString(message('MATLAB:graphics:figurescreenreader:NamedFigureNoAxesWithOtherChildren',...
                        f.Name,join(unique(string(get(nonAxesChildren,{'Type'})),'stable'),', ')),lc_en);
                    else
                        figureDescription=getString(message('MATLAB:graphics:figurescreenreader:NamedFigureNonAxesChildrenMultipleAxes',...
                        f.Name,numel(allAxes),join(unique(string(get(nonAxesChildren,{'Type'})),'stable'),', ')),lc_en);
                    end
                end
            end
            figureDescription=string(figureDescription);
        end

        function[axesDescription,texStrings,latexStrings]=axesDescriptionForDoc(allAxes)




            texStrings=string.empty;
            latexStrings=string.empty;
            import matlab.graphics.internal.FigureScreenReaderManager;
            lc_en=matlab.internal.i18n.locale('en');
            if numel(allAxes)==0
                axesDescription="";
            elseif numel(allAxes)==1



                visibleObjects=findobj(allAxes,'-isa','matlab.graphics.primitive.Data',...
                '-and','-not','-isa','matlab.graphics.mixin.SceneNodeGroup',...
                '-and','-property','Type','-and','Visible','on');
                visibleObjects=visibleObjects(end:-1:1);
                titleString=getTitleString(allAxes);
                if strlength(titleString)>0
                    if isempty(visibleObjects)
                        axesDescription=" "+getString(message('MATLAB:graphics:figurescreenreader:TitledSingleAxesDescriptionEmpty',titleString),lc_en);
                    elseif numel(visibleObjects)==1
                        axesDescription=" "+getString(message('MATLAB:graphics:figurescreenreader:TitledSingleAxesDescriptionSingleObject',titleString,visibleObjects.Type),lc_en);
                    else
                        visibleObjectTypes=join(unique(string(get(visibleObjects,{'Type'})),'stable'),', ');
                        axesDescription=" "+getString(message('MATLAB:graphics:figurescreenreader:TitledSingleAxesDescriptionNonEmpty',titleString,numel(visibleObjects),visibleObjectTypes),lc_en);
                    end
                    if~isempty(titleString)
                        if strcmp(allAxes.Title.Interpreter,"tex")
                            texStrings=[titleString];
                        elseif strcmp(allAxes.Title.Interpreter,"latex")
                            latexStrings=[titleString];
                        end
                    end
                else
                    if isempty(visibleObjects)
                        axesDescription=" "+getString(message('MATLAB:graphics:figurescreenreader:UntitledSingleAxesDescriptionEmpty'),lc_en);
                    elseif numel(visibleObjects)==1
                        axesDescription=" "+getString(message('MATLAB:graphics:figurescreenreader:UntitledSingleAxesDescriptionSingleObject',visibleObjects.Type),lc_en);
                    else
                        visibleObjectTypes=join(unique(string(get(visibleObjects,{'Type'})),'stable'),', ');
                        axesDescription=" "+getString(message('MATLAB:graphics:figurescreenreader:UntitledSingleAxesDescriptionNonEmpty',numel(visibleObjects),visibleObjectTypes),lc_en);
                    end
                end
                namedAxesContent=FigureScreenReaderManager.getNamedAxesContent(allAxes);
                if strlength(namedAxesContent)>=1
                    axesDescription=axesDescription+" "+namedAxesContent;
                end

            elseif numel(allAxes)>1
                axesDescription="";


                for k=1:numel(allAxes)



                    visibleObjects=findobj(allAxes(k).Children,'-isa','matlab.graphics.primitive.Data',...
                    '-and','-not','-isa','matlab.graphics.mixin.SceneNodeGroup',...
                    '-and','-property','Type','-and','Visible','on');
                    visibleObjects=visibleObjects(end:-1:1);
                    titleString=getTitleString(allAxes(k));
                    if strlength(titleString)>0
                        if isempty(visibleObjects)
                            axesDescription=axesDescription+" "+getString(message('MATLAB:graphics:figurescreenreader:TitledMultipleAxesDescriptionEmpty',...
                            k,titleString),lc_en);
                        elseif numel(visibleObjects)==1
                            axesDescription=axesDescription+" "+getString(message('MATLAB:graphics:figurescreenreader:TitledMultipleAxesDescriptionSingleObject',...
                            k,titleString,visibleObjects.Type),lc_en);
                        else
                            visibleObjectTypes=join(unique(string(get(visibleObjects,{'Type'})),'stable'),', ');
                            axesDescription=axesDescription+" "+getString(message('MATLAB:graphics:figurescreenreader:TitledMultipleAxesDescriptionNonEmpty',...
                            k,titleString,numel(visibleObjects),visibleObjectTypes),lc_en);
                        end
                        if~isempty(titleString)
                            if strcmp(allAxes(k).Title.Interpreter,"tex")
                                texStrings(end+1)=titleString;%#ok<AGROW> 
                            elseif strcmp(allAxes(k).Title.Interpreter,"latex")
                                latexStrings(end+1)=titleString;%#ok<AGROW> 
                            end
                        end
                    else
                        if isempty(visibleObjects)
                            axesDescription=axesDescription+" "+getString(message('MATLAB:graphics:figurescreenreader:UntitledMultipleAxesDescriptionEmpty',...
                            k),lc_en);
                        elseif numel(visibleObjects)==1
                            axesDescription=axesDescription+" "+getString(message('MATLAB:graphics:figurescreenreader:UntitledMultipleAxesDescriptionSingleObject',...
                            k,visibleObjects.Type),lc_en);
                        else
                            visibleObjectTypes=join(unique(string(get(visibleObjects,{'Type'})),'stable'),', ');
                            axesDescription=axesDescription+" "+getString(message('MATLAB:graphics:figurescreenreader:UntitledMultipleAxesDescriptionNonEmpty',...
                            k,numel(visibleObjects),visibleObjectTypes),lc_en);
                        end
                    end
                    namedAxesContent=FigureScreenReaderManager.getNamedAxesContent(allAxes(k));
                    if strlength(namedAxesContent)>=1
                        axesDescription=axesDescription+" "+namedAxesContent;
                    end
                end
            end
        end

        function chartDescription=chartDescriptionForDoc(f)


            lc_en=matlab.internal.i18n.locale('en');
            allCharts=findobj(f.Children,'-isa','matlab.graphics.chart.Chart','Visible','on','-function',@(h)isprop(h,'Title')&&~isempty(h.Title));
            allCharts=allCharts(end:-1:1);
            if numel(allCharts)==0
                chartDescription="";
            else

                chartDescription=" "+getString(message('MATLAB:graphics:figurescreenreader:TitledSingleChart',allCharts(1).Type,allCharts(1).Title),lc_en);
                for k=2:numel(allCharts)
                    chartDescription=chartDescription+" "+getString(message('MATLAB:graphics:figurescreenreader:TitledSingleChart',allCharts(k).Type,allCharts(k).Title),lc_en);
                end
            end
        end

        function gcaDescription=gcaDescription(ax)


            if~isa(ax,'matlab.graphics.axis.Axes')

                if isprop(ax,'Type')
                    gcaDescription=getString(message('MATLAB:graphics:figurescreenreader:ChartWithType',ax.Type));
                else
                    gcaDescription="";
                end
                return
            end
            visibleObjects=findobj(ax.Children,'flat','Visible','on','-property','Type');
            if~isempty(visibleObjects)
                visibleObjectTypes=join(unique(string(get(visibleObjects,{'Type'})),'stable'),', ');
            end
            axesTitle=getTitleString(ax);
            if strlength(axesTitle)==0
                if isempty(visibleObjects)
                    gcaDescription=getString(message('MATLAB:graphics:figurescreenreader:UntitledCurrentAxesDescriptionEmpty'));
                else
                    gcaDescription=getString(message('MATLAB:graphics:figurescreenreader:UntitledCurrentAxesDescriptionNonEmpty',...
                    numel(visibleObjects),visibleObjectTypes));
                end
            else
                if isempty(visibleObjects)
                    gcaDescription=getString(message('MATLAB:graphics:figurescreenreader:TitledCurrentAxesDescriptionEmpty',axesTitle));
                else
                    gcaDescription=getString(message('MATLAB:graphics:figurescreenreader:TitledCurrentAxesDescriptionNonEmpty',...
                    axesTitle,numel(visibleObjects),visibleObjectTypes));
                end
            end
        end

        function updateAriaLabel(hFig,ariaLabel)


            channel="/embeddedfigure/ServerToClient"+matlab.ui.internal.FigureServices.getUniqueChannelId(hFig);

            ariaUpdateFcn=@()message.publish(channel,struct('eventType','AriaLabel','value',ariaLabel));



            matlab.ui.internal.dialog.DialogHelper.dispatchWhenViewIsReady(hFig,ariaUpdateFcn);
        end

        function updateAriaLiveTextContent(hFig,textContent)


            channel="/embeddedfigure/ServerToClient"+matlab.ui.internal.FigureServices.getUniqueChannelId(hFig);

            ariaUpdateFcn=@()message.publish(channel,struct('eventType','AriaLiveTextContent','value',textContent));



            matlab.ui.internal.dialog.DialogHelper.dispatchWhenViewIsReady(hFig,ariaUpdateFcn);
        end

        function hDescendants=getAnnouncedNonAxesFigureDescendants(f,additionalExcludedClasses)




            excludedTypes=["legend","colorbar"];
            excludedClasses="matlab.graphics.layout.Layout";



            if nargin>=2&&~isempty(additionalExcludedClasses)
                excludedClasses=[excludedClasses,additionalExcludedClasses(:)'];
            end

            hChildren=findobj(f.Children,'flat','-property','Visible','Visible','on','-function',...
            @(h)isprop(h,'Type')&&~ismember(h.Type,excludedTypes)&&~any(arrayfun(@(mixin)isa(h,mixin),excludedClasses)));
            hCharts=findobj(f.Children,'-isa','matlab.graphics.chart.Chart','-property','Visible','Visible','on','-function',...
            @(h)isprop(h,'Type'));
            hDescendants=[hChildren(:)',hCharts(:)'];
            hDescendants=unique(hDescendants(end:-1:1),'stable');
        end

        function namedAxesContent=getNamedAxesContent(ax)



            namedAxesContent="";
            if~isempty(ax.Children)
                childrenWithManualDisplayName=findobj(ax,'-depth',1,'DisplayNameMode','manual');
                namedChildren=findobj(childrenWithManualDisplayName,'flat',...
                '-function',@(h)isprop(h,'DisplayName')&&~isempty(h.DisplayName));
                namedChildren=namedChildren(end:-1:1);
                if numel(namedChildren)>1

                    namedAxesContent=getString(message('MATLAB:graphics:figurescreenreader:AxesNamedChildren',...
                    join(unique(string(get(namedChildren,{'DisplayName'})),'stable'),', ')));
                elseif numel(namedChildren)==1

                    namedAxesContent=getString(message('MATLAB:graphics:figurescreenreader:AxesNamedSingleChild',...
                    namedChildren.DisplayName));
                end
            end
        end

        function validState=validateFigureContent(f,allAxes)%#ok<INUSL>






            validState=isempty(intersect(get(allAxes,'Tag'),{'PlotMatrixHistAx','PlotMatrixScatterAx','PlotMatrixBigAx'}));
        end
    end
end


function titleString=getTitleString(ax)


    try
        if isa(ax,'matlab.graphics.axis.Axes')&&~isempty(ax.Title_IS)
            titleString=string(deblank(ax.Title_IS.String));
            if numel(titleString)>1

                titleString=strjoin(titleString);
            end
        else
            titleString="";
        end
    catch
        titleString="";
    end
end

function visibleAndImageAxes=getVisibleAndImageAxes(f)




    allAxes=findobj(f.Children,'-isa','matlab.graphics.axis.AbstractAxes');
    visibleAxes=findobj(allAxes,'flat','-property','Visible','Visible','on');
    visibleAxes=visibleAxes(end:-1:1);
    imageAxes=findobj(allAxes,'flat','-function',@(ax)~isempty(findobj(ax.Children,'flat','-isa','matlab.graphics.primitive.Image')));
    imageAxes=imageAxes(end:-1:1);
    visibleAndImageAxes=unique([visibleAxes(:);imageAxes(:)]','stable');
end


function outsstr=removeInvalidXMLChars(instr)


    str=char(instr);
    uCode=double(str);
    str=str(uCode>=20|abs(uCode-9)<0.01|abs(uCode-10)<0.01|abs(uCode-13)<0.01);
    outsstr=string(str);
end