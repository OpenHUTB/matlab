function[printFigH,errMsg]=printCmd(blockH,dialog,config,method,varargin)






    global gSigBuildOpenInvisibleBlockH;


    forceOpen=false;


    filePath='';
    errMsg='';

    if isempty(dialog)||~ishghandle(dialog,'figure')


        forceOpen=true;



        gSigBuildOpenInvisibleBlockH=blockH;

        open_system(blockH,'OpenFcn');
        dialog=get_param(blockH,'UserData');
    end
    UD=get(dialog,'UserData');

    switch lower(method)
    case 'dlg'

        device='-v';
    case 'export'

        [filePath,ext]=print_file_select(UD.simulink.subsysH);
        if isempty(filePath)
            cleanupGlobal();
            return;
        end
        device=['-d',ext];
    case 'copytoclipboard'

        device='-dmeta';
    case 'fig'

        figH=printUD(UD,config,'figure');
        set(figH,'Visible','on','Toolbar','figure');
        cleanupGlobal();
        return;
    case 'copy'

        figH=printUD(UD,config,'figure');
        set(figH,'Visible','on','Toolbar','figure');
        uimenufcn(gcf,'EditCopyFigure');
        set(figH,'Visible','off','Toolbar','figure');
        cleanupGlobal();
        return;
    case 'prnt'

        device='-dps';
    case 'figure'

        [printFigH,errMsg]=printUD(UD,config,'figure');
        cleanupGlobal();
        return;
    case 'cmd'



        [printFigH,errMsg]=printUD(UD,config,'cmd',varargin);
        cleanupGlobal();
        return;
    otherwise
        error(message('sigbldr_ui:printCmd:unknownMethod'));
    end


    if isempty(filePath)
        if strcmp(device,'-v')
            printUD(UD,config,'dlg');
        else

            printUD(UD,config,'cmd',{device});
        end
    else

        printUD(UD,config,'cmd',{device,filePath});
    end

    cleanupGlobal();




    function cleanupGlobal()

        if(forceOpen)
            close_internal(UD);
        end


        evalin('base','clear(''global'',''gSigBuildOpenInvisibleBlockH'')');
    end

    function[filePath,ext]=print_file_select(blockH)

        modelH=bdroot(blockH);
        modelName=get_param(modelH,'Name');
        blockName=get_param(blockH,'Name');
        filePath='';
        ext='';

        blockName=removechars(blockName,sprintf('<>?:",./~`{}[]!@#$%%^&*()-+=|\n\r\t\b\f\\'''));
        blockName=strrep(blockName,' ','_');

        extd={'*.ps','Postscript (*.ps)';...
        '*.eps','Encapsulated Postscript (*.eps)';...
        '*.psc','Color Postscript (*.psc)';...
        '*.tiff','Tiff (*.tiff)';...
        '*.png','Png (*.png)';...
        '*.jpeg','Jpeg(*.jpeg)'};

        dfn=[modelName,'_',blockName,'.ps'];
        [fn,pn,filterindex]=uiputfile(extd,getString(message('sigbldr_ui:printCmd:Export')),dfn);
        if~isequal(filterindex,0)
            ext=extd{filterindex,1};
            ext=ext(3:end);
        end
        if ischar(fn)
            filePath=[pn,fn];
        end
    end

    function out=removechars(in,chars)

        out=in;
        for c=chars(:)'
            out=strrep(out,c,'');
        end
    end
end
