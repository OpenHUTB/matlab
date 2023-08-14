function[pj,pt]=printjobContentChanges(state,pj,varargin)











    narginchk(2,3);


    if~ischar(state)||~(strcmp(state,'set')||strcmp(state,'restore'))
        error(message('MATLAB:printjobcontentchanges:invalidFirstArgument'))
    end

    invalidPrintJob=false;
    switch class(pj)
    case 'struct'
        if~(isfield(pj,'Tag')&&strcmp(pj.Tag,'printjob'))
            invalidPrintJob=true;
        end
    case 'matlab.graphics.internal.mlprintjob'
        if~(isprop(pj,'Tag')&&strcmp(pj.Tag,'printjob'))
            invalidPrintJob=true;
        end
    otherwise
        invalidPrintJob=true;
    end

    if invalidPrintJob
        error(message('MATLAB:printjobcontentchanges:invalidSecondArgument'))
    end

    if isequal(state,'set')

        narginchk(2,2);

        if pj.doTransform



            fireprintbehavior(pj,'PrePrintCallback');
        end


        pj.temp.allContents=findall(pj.Handles{1});




        instance=matlab.graphics.internal.printEnhanceTextures.getInstance();
        if instance.needEnhanceOutput(pj.temp.allContents)
            pj.EnhanceTextures=1;
        end

        pj.temp.test.SelectionState=[];
        if pj.doTransform

            matlab.graphics.internal.export.updateSelectionState(pj,'remove');
        end


        pj=localHandleNoUIFlag(pj,'hide');


        pj.temp.test.processPT=[];
        if pj.doTransform
            pt=getprinttemplate(pj.Handles{1});
            if isempty(pt)
                pt=printtemplate;
                pt.DebugMode=pj.DebugMode;
            end
            if isfigure(pj.Handles{1})&&~isempty(pt)
                pt=ptpreparehg(pt,pj.Handles{1});
                pj.temp.test.processPT='set';
            else
                pt=printtemplate;
                pt.DebugMode=pj.DebugMode;
            end
        else
            pt=printtemplate;
            pt.DebugMode=pj.DebugMode;
        end


        pj.temp.test.adjustGridLineStyles=[];
        pj=adjustGridLineStyles('save',pj);


        pj.temp.test.UpdateColorsIfNeeded=[];
        pt=localUpdateColorsIfNeeded(pj,pt,'invert');












        if pj.Verbose&&pj.isPrintDriver()&&isequal(pt.VersionNumber,1)
            setappdata(groot,'PrintingFigure',pj.Handles{1});
            pj.temp.removeAppdata=true;
        else
            pj.temp.removeAppdata=false;
        end
        pt.v2hgdata.Undithered=0;
        pj.temp.test.contrastcolors=[];
        if pj.doTransform&&~blt(pj,pj.Handles{1})
            pt.v2hgdata.Undithered=1;
            contrastcolors('save',pj.Handles{1});
            pj.temp.test.contrastcolors='set';
        end
    else

        narginchk(3,3);
        pt=varargin{1};


        if pj.doTransform&&~isempty(pt)

            if isfield(pt,'v2hgdata')
                if pt.v2hgdata.Undithered
                    contrastcolors('restore',pj.Handles{1});
                    pj.temp.test.contrastcolors='restore';
                    pt.v2hgdata.Undithered=0;
                end

                if pj.temp.removeAppdata&&isappdata(groot,'PrintingFigure')
                    rmappdata(groot,'PrintingFigure');
                end


                pt=localUpdateColorsIfNeeded(pj,pt,'restore');
            end


            pj=adjustGridLineStyles('restore',pj);


            ptrestorehg(pt,pj.Handles{1});
            pj.temp.test.processPT='restore';
        end


        pj=localHandleNoUIFlag(pj,'show');


        matlab.graphics.internal.export.updateSelectionState(pj,'restore');


        if pj.EnhanceTextures
            pj.EnhanceTextures=0;
        end




        if pj.doTransform
            fireprintbehavior(pj,'PostPrintCallback');
        end
    end
end



function pj=localHandleNoUIFlag(pj,state)



    if~pj.PrintUI&&strcmp(state,'hide')

        toBeHidden=findall(pj.temp.allContents,{'type','uicontrol','-or',...
        'type','uitable','-or',...
        'type','hgjavacomponent'},'-and',...
        'visible','on','-depth',0);
        set(toBeHidden,'Visible','off');
        pj.temp.restoreUI=toBeHidden;

        pj.PrintUI=1;
    elseif strcmp(state,'show')&&isfield(pj.temp,'restoreUI')&&~isempty(pj.temp.restoreUI)

        ok=ishghandle(pj.temp.restoreUI);
        set(pj.temp.restoreUI(ok),'Visible','on');
        pj.PrintUI=0;
    end
end

function pt=localUpdateColorsIfNeeded(pj,pt,state)
    switch(state)
    case 'invert'
        pt.v2hgdata.Inverted=0;
        pt.v2hgdata.OrigColor=[];
        if~pj.doTransform
            return;
        end

        if isfield(pj.temp,'COFigureBackground')
            figbkcolorpref=pj.temp.COFigureBackground;
        else
            figbkcolorpref=[];
        end

        [modified,inverted,origColor]=modifyColorsForPrint(...
        'invert',pj.Handles{1},pj.temp.HonorCOPrefs,...
        pj.temp.outputUsesPainters,...
        strcmp(pj.Driver,'bitmap'),...
        figbkcolorpref);
        if modified
            pt.v2hgdata.Inverted=inverted;
            pt.v2hgdata.OrigColor=origColor;
            pj.temp.test.UpdateColorsIfNeeded='set';
        end
    case 'restore'
        if pj.doTransform
            modifyColorsForPrint('revert',pj.Handles{1},...
            pt.v2hgdata.Inverted,pt.v2hgdata.OrigColor)

            if isfield(pt.v2hgdata,'OrigColor')
                pt.v2hgdata=rmfield(pt.v2hgdata,'OrigColor');
            end
            pj.temp.test.UpdateColorsIfNeeded='restore';
        end
        pt.v2hgdata.Inverted=0;
    end

end
