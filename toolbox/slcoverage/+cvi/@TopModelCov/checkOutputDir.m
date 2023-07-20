function newOutputDir=checkOutputDir(outputDir,errorReporting)








    if nargin<2
        errorReporting=2;
    end
    newOutputDir='';
    if~isempty(outputDir)&&isfullpath(outputDir)
        newOutputDir=outputDir;
        [~,isReadOnly]=checkFolder(newOutputDir);
        if isReadOnly
            newOutputDir=reportReadOnly(outputDir,errorReporting);
        end
    else
        pDir=pwd;
        [~,isReadOnly]=checkFolder(pDir);
        if isReadOnly
            pDir=reportReadOnly(pDir,errorReporting);
        end

        if isempty(pDir)
            return;
        else
            newOutputDir=fullfile(pDir,outputDir);
        end
    end

    if~isempty(newOutputDir)
        [doesExist,isReadOnly]=checkFolder(newOutputDir);
        if~doesExist
            mkdir(newOutputDir);
        elseif isReadOnly
            newOutputDir=reportReadOnly(newOutputDir,errorReporting);
        end
    end
end

function[doesExist,isReadonly]=checkFolder(pDir)
    isReadonly=false;
    doesExist=isfolder(pDir);
    if~isempty(pDir)
        [~,userWrite]=cvi.ReportUtils.checkUserWrite(pDir);
        isReadonly=~userWrite;
    end
end


function pDir=reportReadOnly(pDir,errorReporting)
    msg=message('Slvnv:simcoverage:ioerrors:ReadOnlyDirectory');
    if errorReporting==2

        answr=questdlg(getString(msg),'Simulink Coverage','OK','Cancel','OK');
        if strcmpi(answr,'ok')
            str=getString(msg);
            pDir=uigetdir(pDir,str);
            if~ischar(pDir)
                pDir=[];
            end
        end
    elseif errorReporting==1

        error(msg);
    else
        pDir=[];
    end
end


function isfull=isfullpath(p)

    p(p=='/')='\';
    isfull=p(1)=='\'||contains(p,':');
end
