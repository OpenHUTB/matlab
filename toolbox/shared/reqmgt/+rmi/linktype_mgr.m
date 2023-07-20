function out=linktype_mgr(method,varargin)




    persistent ltypeName ltypeArray ltypeExt hasAll;
    mlock;

    switch(method)
    case 'clear'
        ltypeName=[];
        ltypeArray=[];
        ltypeExt=[];
        hasAll=[];

    case 'add'
        uddLinkType=varargin{1};


        regName=uddLinkType.Registration;
        if isfield(ltypeName,regName)
            error(message('Slvnv:reqmgt:linktype_mgr:DuplicateRegistration',regName));
        end
        ltypeName.(regName)=uddLinkType;



        manageTypesList(uddLinkType);


        regExts=uddLinkType.Extensions;
        for ext=regExts(:)'
            if isfield(ltypeExt,ext{1}(2:end))
                newValue=ltypeExt.(ext{1}(2:end));
                newValue(end+1)=uddLinkType;%#ok<AGROW>
            else
                newValue=uddLinkType;
            end
            ltypeExt.(ext{1}(2:end))=newValue;
        end
        out=[];

    case 'remove'

        uddLinkType=varargin{1};
        ltypeArray(ltypeArray==uddLinkType)=[];


        regName=uddLinkType.Registration;
        if isfield(ltypeName,regName)
            ltypeName=rmfield(ltypeName,regName);
        end


        regExts=uddLinkType.Extensions;
        for ext=regExts(:)'
            if isfield(ltypeExt,ext{1}(2:end))
                extLinkTypes=ltypeExt.(ext{1}(2:end));
                if all(extLinkTypes==uddLinkType)
                    ltypeExt=rmfield(ltypeExt,ext{1}(2:end));
                else
                    extLinkTypes(extLinkTypes==uddLinkType)=[];
                    ltypeExt.(ext{1}(2:end))=extLinkTypes;
                end
            end
        end

        manageTypesList(regName);

    case 'reset'
        regTargets=rmi.settings_mgr('default','regTargets');
        rmi.settings_mgr('set','regTargets',regTargets);
        manageTypesList('');
        rmi.initialize();

    case 'resolveByFileExt'
        if isempty(ltypeName)
            rmi('init');
        end
        doc=varargin{1};
        dots=strfind(doc,'.');
        if isempty(dots)
            out=[];
        else
            ext=doc(dots(end)+1:end);
            if ispc()
                ext=lower(ext);
            end
            if isempty(ltypeExt)||~isfield(ltypeExt,ext)
                out=[];
            else
                out=ltypeExt.(ext);
            end
        end

    case 'resolveByRegName'
        if isempty(ltypeName)
            rmi('init');
        end
        regName=varargin{1};


        if isfield(ltypeName,regName)
            out=ltypeName.(regName);


        elseif any(strcmp(regName,{'WORD','HTML','EXCEL','doors'}))

            newTypes={'linktype_rmi_word','linktype_rmi_html','linktype_rmi_excel','linktype_rmi_doors'};
            newType=newTypes(strcmp(regName,{'WORD','HTML','EXCEL','doors'}));
            if isfield(ltypeName,newType{1})
                out=ltypeName.(newType{1});
            else
                out=[];
            end


        elseif strcmp(regName,'linktype_rmi_simulink')
            try
                rmi.loadLinktype('linktype_rmi_simulink');
                if dig.isProductInstalled('Simulink')&&is_simulink_loaded()
                    rmipref('DuplicateOnCopy');
                end
                out=rmi.linktype_mgr('resolveByRegName',regName);
            catch ex %#ok<NASGU>
                out=[];
            end


        elseif strcmp(regName,'linktype_rmi_testmgr')
            if~isempty(which('stm.view'))
                rmi.loadLinktype('linktype_rmi_testmgr');
                out=rmi.linktype_mgr('resolveByRegName',regName);
            else
                out=[];
            end

        else
            out=[];
        end

    case 'resolve'
        sys=varargin{1};
        ext=varargin{2};
        if isempty(ltypeName)
            rmi('init');
        end
        switch(lower(sys))
        case 'other'
            if isfield(ltypeExt,ext(2:end))
                extMatches=ltypeExt.(ext(2:end));
                out=extMatches(1);
            else
                out=[];
            end
        case 'doors'
            out=ltypeName.('linktype_rmi_doors');
        otherwise
            if isfield(ltypeName,sys)
                out=ltypeName.(sys);
            else


                out=[];
                if any(strcmp(sys,{'OTHERS','WORD','HTML','EXCEL'}))
                    out=rmi.linktype_mgr('resolve','other',ext);
                end
            end
        end

    case 'is_builtin'
        regname=varargin{1};
        if~ischar(regname)
            regname=regname.Registration;
        end
        whereIs=which(['linktypes.',regname]);
        out=~isempty(whereIs)&&contains(whereIs,matlabroot);

    case 'all'



        if isempty(hasAll)
            if dig.isProductInstalled('Simulink')&&license('test','simulink')&&is_simulink_loaded()
                if~isfield(ltypeName,'linktype_rmi_simulink')
                    rmi.loadLinktype('linktype_rmi_simulink');
                    rmipref('DuplicateOnCopy');
                end
                if~isfield(ltypeName,'linktype_rmi_testmgr')
                    if~isempty(which('stm.view'))
                        rmi.loadLinktype('linktype_rmi_testmgr');
                    end
                end
                hasAll=true;
            end
        end
        out=ltypeArray;


    otherwise
        error(message('Slvnv:reqmgt:linktype_mgr:UnknownMethod',method));
    end

    function manageTypesList(typeData)




















        persistent preferredOrder

        if isempty(preferredOrder)
            preferredOrder={...
            'linktype_rmi_slreq',...
            'linktype_rmi_matlab',...
            'linktype_rmi_simulink',...
            'linktype_rmi_data',...
            'linktype_rmi_testmgr',...
            'linktype_rmi_word',...
            'linktype_rmi_excel',...
            'linktype_rmi_doors',...
            'linktype_rmi_oslc',...
            'linktype_rmi_url',...
            'linktype_rmi_text',...
            'linktype_rmi_html',...
            'linktype_rmi_pdf'};

        end

        if ischar(typeData)

            if isempty(typeData)
                preferredOrder={};
            else
                idx=strcmp(preferredOrder,typeData);
                preferredOrder(idx)=[];
            end
            return;
        end

        myRank=find(strcmp(preferredOrder,typeData.Registration));

        if isempty(myRank)

            preferredOrder=[{typeData.Registration},preferredOrder];
            ltypeArray=[typeData,ltypeArray];
            return;
        end


        for i=1:numel(ltypeArray)
            nextMember=ltypeArray(i);
            nextRank=find(strcmp(preferredOrder,nextMember.Registration));
            if myRank<nextRank
                ltypeArray=[ltypeArray(1:i-1),typeData,ltypeArray(i:end)];
                return;
            end
        end


        ltypeArray=[ltypeArray,typeData];
    end

end




