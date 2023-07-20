function[Tab]=getExtensionDialogSchema(hSrc,schemaName)












































    pp=fieldnames(hSrc.get());
    tlmg_props=pp(strmatch('tlmg',pp));


    [nm,tt]=l_GetUIStrings(hSrc,tlmg_props);







    wl=l_GetDefaultWidgetList(hSrc,nm,tt,tlmg_props);







    wl.tlmgTbExeDir.Enabled=false;
    wl.tlmgTbExeDir.Visible=false;
    wl.tlmgEnabledVerifyButton=l_genVerifyButton(hSrc,'tlmgEnabledVerifyButton',nm,tt,true);
    wl.tlmgDisabledVerifyButton=l_genVerifyButton(hSrc,'tlmgDisabledVerifyButton',nm,tt,false);

    wl.tlmgCompilerSelect=l_comboboxArray(hSrc,'tlmgCompilerSelect','tlmgCompilerSelectDetected',nm,tt);

    wl.tlmgTargetOSSelect=l_combobox(hSrc,'tlmgTargetOSSelect',findtype('tlmgTargetOSSelectEnumT'),nm,tt);


    wl.tlmgCombinedCtrlPanel=l_panelWidget(hSrc,...
    'tlmgCombinedCtrlPanel',...
    {});

    wl.tlmgMemMapPanel=l_panelWidget(hSrc,...
    'tlmgMemMapPanel',...
    {});

    wl.tlmgCombinedGroup=l_groupWidget(hSrc,...
    'Combined TLM Socket','tlmgCombinedGroup',...
    {});

    wl.tlmgMemMapInputGroup=l_groupWidget(hSrc,...
    'Input Data TLM Socket','tlmgMemMapInputGroup',...
    {});

    wl.tlmgMemMapOutputGroup=l_groupWidget(hSrc,...
    'Output Data TLM Socket','tlmgMemMapOutputGroup',...
    {});

    wl.tlmgIPXactFilePathPanel=l_panelHWidget(hSrc,...
    'tlmgIPXactFilePathPanel',...
    {});

    wl.tlmgIPXactGroup=l_groupHWidget(hSrc,...
    'Import IP-XACT File','tlmgIPXactGroup',...
    {});

    wl.tlmgMemMapInputOutputPanel=l_panelHWidget(hSrc,...
    'tlmgMemMapInputOutputPanel',...
    {});

    wl.tlmgMultiCtrlGroup=l_groupWidget(hSrc,...
    'Control TLM Socket','tlmgCtrlGroup',...
    {});

    wl.tlmgMultiPanel=l_panelWidget(hSrc,...
    'tlmgMultiPanel',...
    {});

    wl.tlmgCombinedTimingPanel=l_panelWidget(hSrc,...
    'tlmgCombinedTimingPanel',...
    {});

    wl.tlmgMultiTimingPanel=l_panelWidget(hSrc,...
    'tlmgMultiTimingPanel',...
    {});

    wl.tlmgTimingGroup=l_groupWidget(hSrc,...
    'Combined Interface Timing','tlmgTimingGroup',...
    {});

    wl.tlmgTimingInputGroup=l_groupWidget(hSrc,...
    'Input Data Interface Timing','tlmgTimingInputGroup',...
    {});

    wl.tlmgTimingOutputGroup=l_groupWidget(hSrc,...
    'Output Data Interface Timing','tlmgTimingOutputGroup',...
    {});

    wl.tlmgTimingCtrlGroup=l_groupWidget(hSrc,...
    'Control Interface Timing','tlmgTimingCtrlGroup',...
    {});

    wl.tlmgAlgoProcGroup=l_groupWidget(hSrc,...
    'Algorithm Processing','tlmgAlgoProcGroup',...
    {});

    wl.tlmgCompProcGroup=l_groupWidget(hSrc,...
    'Interface Processing','tlmgCompProcGroup',...
    {});

    wl.tlmgTbGroup=l_groupWidget(hSrc,...
    'Testbench Generation','tlmgTbGroup',...
    {});

    wl.tlmgTbBtnGroup=l_groupWidget(hSrc,...
    'Component Verification','tlmgTbBtnGroup',...
    {});

    wl.tlmgTbBtnPanel=l_panelHWidget(hSrc,...
    'tlmgTbBtnPanel',...
    {});

    wl.tlmgGenSockOptsPanel=l_panelWidget(hSrc,...
    'tlmgGenSockOptsPanel',...
    {});

    wl.tlmgGenProcOptsPanel=l_panelWidget(hSrc,...
    'tlmgGenProcOptsPanel',...
    {});

    wl.tlmgGenTimeOptsPanel=l_panelWidget(hSrc,...
    'tlmgGenTimeOptsPanel',...
    {});

    wl.tlmgTbOptsPanel=l_panelWidget(hSrc,...
    'tlmgTbOptsPanel',...
    {});

    wl.tlmgSCMLCcPanel=l_panelWidget(hSrc,...
    'tlmgSCMLCcPanel',...
    {});

    wl.tlmgCcGroup=l_groupWidget(hSrc,...
    'Compiler Options','tlmgCcGroup',...
    {});

    wl.tlmgNamingGroup=l_groupWidget(hSrc,...
    'Component Naming','tlmgNamingGroup',...
    {});

    wl.tlmgCcOptsPanel=l_panelWidget(hSrc,...
    'tlmgCcOptsPanel',...
    {});








    wl=l_SetVisAndEn(hSrc,wl);






    wl.tlmgCombinedCtrlPanel=l_panelWidgetAdd(wl.tlmgCombinedCtrlPanel,...
    {wl.tlmgCommandStatusRegOnOff,...
    wl.tlmgTestAndSetRegOnOff,...
    wl.tlmgTunableParamRegOnOff});


    wl.tlmgMemMapPanel=l_panelWidgetAdd(wl.tlmgMemMapPanel,...
    {wl.tlmgComponentAddressing,...
    wl.tlmgAutoAddressSpecType});

    wl.tlmgCombinedGroup=l_groupWidgetAdd(wl.tlmgCombinedGroup,...
    {wl.tlmgMemMapPanel,wl.tlmgCombinedCtrlPanel});

    wl.tlmgMemMapInputGroup=l_groupWidgetAdd(wl.tlmgMemMapInputGroup,...
    {wl.tlmgComponentAddressingInput,...
    wl.tlmgAutoAddressSpecTypeInput});

    wl.tlmgMemMapOutputGroup=l_groupWidgetAdd(wl.tlmgMemMapOutputGroup,...
    {wl.tlmgComponentAddressingOutput,...
    wl.tlmgAutoAddressSpecTypeOutput});

    wl.tlmgMemMapInputOutputPanel=l_panelHWidgetAdd(wl.tlmgMemMapInputOutputPanel,...
    {wl.tlmgMemMapInputGroup,wl.tlmgMemMapOutputGroup});


    wl.tlmgMultiCtrlGroup=l_groupWidgetAdd(wl.tlmgMultiCtrlGroup,...
    {wl.tlmgCommandStatusRegOnOffInoutput,...
    wl.tlmgTestAndSetRegOnOffInoutput,...
    wl.tlmgTunableParamRegOnOffInoutput});

    wl.tlmgMultiPanel=l_panelWidgetAdd(wl.tlmgMultiPanel,...
    {wl.tlmgMemMapInputOutputPanel,wl.tlmgMultiCtrlGroup});

    wl.tlmgIPXactBrowseBtn=l_IPXactButtonWidget('Browse...','browseIPXactFile');



    wl.tlmgIPXactFilePathPanel=l_panelHWidgetAdd(wl.tlmgIPXactFilePathPanel,...
    {wl.tlmgIPXactPath,wl.tlmgIPXactBrowseBtn});

    wl.tlmgIPXactGroup=l_groupWidgetAdd(wl.tlmgIPXactGroup,...
    {wl.tlmgIPXactFilePathPanel,wl.tlmgIPXactUnmapped,wl.tlmgIPXactUnmappedSig,wl.tlmgSCMLOnOff});

    wl.tlmgGenSockOptsPanel=l_panelWidgetAdd(wl.tlmgGenSockOptsPanel,...
    {wl.tlmgComponentSocketMapping,wl.tlmgCombinedGroup,wl.tlmgMultiPanel,wl.tlmgIPXactGroup});



    wl.tlmgAlgoProcGroup=l_groupWidgetAdd(wl.tlmgAlgoProcGroup,...
    {wl.tlmgProcessingType,...
    wl.tlmgAlgorithmProcessingTime});

    wl.tlmgCompProcGroup=l_groupWidgetAdd(wl.tlmgCompProcGroup,...
    {wl.tlmgIrqPortOnOff});

    wl.tlmgGenProcOptsPanel=l_panelWidgetAdd(wl.tlmgGenProcOptsPanel,...
    {wl.tlmgAlgoProcGroup,wl.tlmgCompProcGroup});



    wl.tlmgTimingGroup=l_groupWidgetAdd(wl.tlmgTimingGroup,...
    {wl.tlmgFirstWriteTime,...
    wl.tlmgSubsequentWritesInBurstTime,...
    wl.tlmgFirstReadTime,...
    wl.tlmgSubsequentReadsInBurstTime});

    wl.tlmgCombinedTimingPanel=l_panelWidgetAdd(wl.tlmgCombinedTimingPanel,...
    {wl.tlmgTimingGroup});

    wl.tlmgTimingInputGroup=l_groupWidgetAdd(wl.tlmgTimingInputGroup,...
    {wl.tlmgFirstWriteTimeInput,...
    wl.tlmgSubsequentWritesInBurstTimeInput});

    wl.tlmgTimingOutputGroup=l_groupWidgetAdd(wl.tlmgTimingOutputGroup,...
    {wl.tlmgFirstReadTimeOutput,...
    wl.tlmgSubsequentReadsInBurstTimeOutput});

    wl.tlmgTimingCtrlGroup=l_groupWidgetAdd(wl.tlmgTimingCtrlGroup,...
    {wl.tlmgFirstWriteTimeCtrl,...
    wl.tlmgSubsequentWritesInBurstTimeCtrl,...
    wl.tlmgFirstReadTimeCtrl,...
    wl.tlmgSubsequentReadsInBurstTimeCtrl});

    wl.tlmgMultiTimingPanel=l_panelWidgetAdd(wl.tlmgMultiTimingPanel,...
    {wl.tlmgTimingInputGroup,wl.tlmgTimingOutputGroup,wl.tlmgTimingCtrlGroup});

    wl.tlmgGenTimeOptsPanel=l_panelWidgetAdd(wl.tlmgGenTimeOptsPanel,...
    {wl.tlmgCombinedTimingPanel,wl.tlmgMultiTimingPanel});



    wl.tlmgTbGroup=l_groupWidgetAdd(wl.tlmgTbGroup,...
    {wl.tlmgGenerateTestbenchOnOff,...
    wl.tlmgVerboseTbMessagesOnOff,...
    wl.tlmgRuntimeTimingMode,...
    wl.tlmgInputBufferTriggerMode,...
    wl.tlmgOutputBufferTriggerMode});

    wl.tlmgTbBtnPanel=l_panelHWidgetAdd(wl.tlmgTbBtnPanel,...
    {wl.tlmgEnabledVerifyButton,...
    wl.tlmgDisabledVerifyButton,...
    wl.tlmgTbExeDir,...
    });

    wl.tlmgTbBtnGroup=l_groupWidgetAdd(wl.tlmgTbBtnGroup,...
    {wl.tlmgTbBtnPanel});

    wl.tlmgTbOptsPanel=l_panelWidgetAdd(wl.tlmgTbOptsPanel,...
    {wl.tlmgTbGroup,wl.tlmgTbBtnGroup...
    });


    wl.tlmgSCMLCcPanel=l_panelWidgetAdd(wl.tlmgSCMLCcPanel,...
    {wl.tlmgSCMLIncludePath,...
    wl.tlmgSCMLLibPath,...
    wl.tlmgSCMLLibName,...
    wl.tlmgSCMLLoggingLibName});

    wl.tlmgCcGroup=l_groupWidgetAdd(wl.tlmgCcGroup,...
    {wl.tlmgSystemCIncludePath,...
    wl.tlmgSystemCLibPath,...
    wl.tlmgSystemCLibName,...
    wl.tlmgTLMIncludePath,...
    wl.tlmgSCMLCcPanel,...
    wl.tlmgTargetOSSelect,...
    wl.tlmgCompilerSelect});

    wl.tlmgNamingGroup=l_groupWidgetAdd(wl.tlmgNamingGroup,...
    {wl.tlmgUserTagForNaming});

    wl.tlmgCcOptsPanel=l_panelWidgetAdd(wl.tlmgCcOptsPanel,...
    {wl.tlmgCcGroup,wl.tlmgNamingGroup});


    wl.tlmgGenSockOptsTab=l_tabWidget('TLM Mapping',wl.tlmgGenSockOptsPanel);
    wl.tlmgGenProcOptsTab=l_tabWidget('TLM Processing',wl.tlmgGenProcOptsPanel);
    wl.tlmgGenTimeOptsTab=l_tabWidget('TLM Timing',wl.tlmgGenTimeOptsPanel);
    wl.tlmgTbOptsTab=l_tabWidget('TLM Testbench',wl.tlmgTbOptsPanel);
    wl.tlmgCcOptsTab=l_tabWidget('TLM Compilation',wl.tlmgCcOptsPanel);



    tabs.Name='TLM Generator';
    tabs.Tag='ddgtag_tlmgTLMGeneratorTabs';
    tabs.Type='tab';
    tabs.Tabs={wl.tlmgGenSockOptsTab,wl.tlmgGenProcOptsTab,wl.tlmgGenTimeOptsTab,wl.tlmgTbOptsTab,wl.tlmgCcOptsTab};



    Tab.Name='TLM Generator';
    Tab.Items={tabs};
    Tab.LayoutGrid=[1,1];

end




function[nm,tt]=l_GetUIStrings(h,tlmg_props)

    for prop=tlmg_props'
        baseId=['TLMGenerator:TLMTargetCC:',prop{:}];


        nameId=[baseId,'_Name'];
        nm.(prop{:})=l_GetUIMessage(h,nameId);


        tipId=[baseId,'_ToolTip'];
        tt.(prop{:})=l_GetUIMessage(h,tipId);
    end
end

function m=l_GetUIMessage(h,id)%#ok<INUSL>
    try
        m=DAStudio.message(id);
    catch ME %#ok<NASGU>


        m=id;
    end
end



function wl=l_GetDefaultWidgetList(h,nm,tt,tlmg_props)
    for prop=tlmg_props'
        propName=prop{:};
        switch(h.getPropType(propName))
        case 'slbool'
            wl.(propName)=l_checkboxWidget(h,propName,nm,tt);
        case{'slint','string','double'}
            wl.(propName)=l_editWidget(h,propName,nm,tt);
        case 'MATLAB array'

        case 'enum'
            proph=findprop(h,propName);
            propDtStr=proph.DataType;
            propDt=findtype(propDtStr);
            wl.(propName)=l_radioButtonWidget(h,propName,propDt,nm,tt);
        otherwise

        end
    end
end


function w=l_checkboxWidget(h,propName,nm,tt)
    w.Type='checkbox';
    w.Name=nm.(propName);
    w.ToolTip=tt.(propName);
    w.Tag=h.genTag(propName);
    w.ObjectProperty=propName;
    w.Mode=1;
    w.ObjectMethod=h.dlgCb.method;
    w.MethodArgs=h.dlgCb.methodArgs;
    w.ArgDataTypes=h.dlgCb.argTypes;
    w.Visible=true;
    w.Enabled=true;
end

function w=l_editWidget(h,propName,nm,tt)
    w.Type='edit';
    w.Name=nm.(propName);
    w.ToolTip=tt.(propName);
    w.Tag=h.genTag(propName);
    w.ObjectProperty=propName;
    w.Mode=1;
    w.ObjectMethod=h.dlgCb.method;
    w.MethodArgs=h.dlgCb.methodArgs;
    w.ArgDataTypes=h.dlgCb.argTypes;
    w.Visible=true;
    w.Enabled=true;

    if(strcmp(propName,'tlmgTbExeDir'))
        w.DialogRefresh=true;
    end

    h.editWidgetList=[h.editWidgetList,{propName}];
end














function w=l_radioButtonWidget(h,propName,propDt,nm,tt)
    w.Type='radiobutton';
    w.Name=nm.(propName);
    w.ToolTip=tt.(propName);
    w.Tag=h.genTag(propName);
    w.ObjectProperty=propName;
    w.Mode=1;
    w.Entries=propDt.Strings';
    w.Values=propDt.Values;
    w.UserData=propDt;
    w.ObjectMethod=h.dlgCb.method;
    w.MethodArgs=h.dlgCb.methodArgs;
    w.ArgDataTypes=h.dlgCb.argTypes;
    w.Visible=true;
    w.Enabled=true;
end



function w=l_combobox(h,propName,propDt,nm,tt)
    w.Type='combobox';
    w.Name=nm.(propName);
    w.ToolTip=tt.(propName);
    w.Tag=h.genTag(propName);
    w.ObjectProperty=propName;
    w.Mode=1;
    w.Entries=propDt.Strings';
    w.Values=propDt.Values;
    w.UserData=propDt;
    w.ObjectMethod=h.dlgCb.method;
    w.MethodArgs=h.dlgCb.methodArgs;
    w.ArgDataTypes=h.dlgCb.argTypes;
    w.Visible=true;
    w.Enabled=true;

    if numel(w.Entries)<2
        w.Enabled=false;
    end
end

function w=l_comboboxArray(h,propName,arrayName,nm,tt)
    w.Type='combobox';
    w.Name=nm.(propName);
    w.ToolTip=tt.(propName);
    w.Tag=h.genTag(propName);
    w.ObjectProperty=propName;
    w.Mode=1;
    w.Entries=h.(arrayName);
    w.ObjectMethod=h.dlgCb.method;
    w.MethodArgs=h.dlgCb.methodArgs;
    w.ArgDataTypes=h.dlgCb.argTypes;
    w.Visible=true;
    w.Enabled=true;

    if numel(w.Entries)<2
        w.Enabled=false;
    end
end



function w=l_genVerifyButton(h,propName,nm,tt,haveTbDir)
    w.Type='pushbutton';
    w.Name=nm.(propName);
    w.ToolTip=tt.(propName);
    w.Tag=h.genTag(propName);
    w.ObjectMethod='verifyTlmComp';
    w.MethodArgs={'%dialog'};
    w.ArgDataTypes={'handle'};
    w.Visible=false;
    w.Enabled=haveTbDir;
    w.Graphical=true;
    w.Alignment=6;

    if(haveTbDir)
        w.ForegroundColor=[0,0,0];
    else
        w.ForegroundColor=[128,128,128];
    end
end



function w=l_IPXactButtonWidget(Name,Tag)
    w.Type='pushbutton';
    w.Name=Name;
    w.ToolTip=Name;
    w.Tag=Tag;
    w.ObjectMethod='pushIPXactButton';
    w.MethodArgs={'%dialog','%tag'};
    w.ArgDataTypes={'handle','string'};
    w.Visible=true;
    w.Enabled=true;
end




function wl=l_SetVisAndEn(hObj,wl)
    wlfn=fieldnames(wl);
    for ii=1:length(wlfn)
        pName=wlfn{ii};
        if isfield(wl.(pName),'Type')
            if(strcmp(wl.(pName).Type,'panel')||...
                strcmp(wl.(pName).Type,'group'))
                continue;
            end
        end
        pVal=hObj.(pName);
        chg=hObj.getDependentChanges(pName,pVal);
        if(~isempty(chg))
            wl=hObj.executeChanges(chg,wl);
        end
    end
end


function g=l_groupWidget(h,name,tag,wl)
    g.Name=name;
    g.Type='group';

    [numrows,numcols,newwl]=l_expandCompoundWidgets(wl);

    g.LayoutGrid=[numrows,numcols];
    g.Items=newwl;
    g.Tag=h.genTag(tag);
    g.Visible=true;
    g.Enabled=true;

end

function g=l_groupWidgetAdd(g,wl)

    [numrows,numcols,newwl]=l_expandCompoundWidgets({g.Items{:},wl{:}});

    g.LayoutGrid=[numrows,numcols];
    g.Items=newwl;
end

function g=l_groupHWidget(h,name,tag,wl)
    g.Name=name;
    g.Type='group';

    [numrows,numcols,newwl]=l_expandCompoundHWidgets(wl);

    g.LayoutGrid=[numrows,numcols];
    g.Items=newwl;
    g.Tag=h.genTag(tag);
    g.Visible=true;
    g.Enabled=true;


end

function g=l_groupHWidgetAdd(g,wl)

    [numrows,numcols,newwl]=l_expandCompoundHWidgets({g.Items{:},wl{:}});

    g.LayoutGrid=[numrows,numcols];
    g.Items=newwl;

end
function p=l_panelWidget(h,tag,wl)
    p.Type='panel';

    [numrows,numcols,newwl]=l_expandCompoundWidgets(wl);

    p.LayoutGrid=[numrows,numcols];
    p.Items=newwl;
    p.Tag=h.genTag(tag);
    p.Visible=true;
    p.Enabled=true;

end

function p=l_panelWidgetAdd(p,wl)

    [numrows,numcols,newwl]=l_expandCompoundWidgets({p.Items{:},wl{:}});

    p.LayoutGrid=[numrows,numcols];
    p.Items=newwl;

end

function p=l_panelHWidget(h,tag,wl)
    p.Type='panel';

    [numrows,numcols,newwl]=l_expandCompoundHWidgets(wl);

    p.LayoutGrid=[numrows,numcols];
    p.Items=newwl;
    p.Tag=h.genTag(tag);
    p.Visible=true;
    p.Enabled=true;

end

function p=l_panelHWidgetAdd(p,wl)

    [numrows,numcols,newwl]=l_expandCompoundHWidgets({p.Items{:},wl{:}});

    p.LayoutGrid=[numrows,numcols];
    p.Items=newwl;

end

function s=l_spacerWidget()
    s.Type='panel';
end

function t=l_tabWidget(name,g)





    t.Name=name;
    t.LayoutGrid=[2,1];
    g.RowSpan=[1,1];
    g.ColSpan=[1,1];
    t.RowStretch=[0,1];
    t.Items={g};
end

function[numrows,numcols,newwl]=l_expandCompoundWidgets(wl)


    numrows=length(wl);
    numcols=1;
    numwidgets=length(wl);
    for w=wl
        curW=w{:};
        if(isa(curW,'tlmg.EditWidget'))
            numcols=2;
            numwidgets=numwidgets+1;
        end
    end

    newwl=cell(1,numwidgets);
    wnum=0;
    for ii=1:numel(wl)
        curW=wl{ii};
        if(isa(curW,'tlmg.EditWidget'))
            leW=curW.getWidgetStructs();
            for jj=1:numel(leW)
                wnum=wnum+1;
                leW{jj}.RowSpan=[ii,ii];
                leW{jj}.ColSpan=[jj,jj];
                newwl{wnum}=leW{jj};
            end
        else
            wnum=wnum+1;
            curW.RowSpan=[ii,ii];
            curW.ColSpan=[1,numcols];
            newwl{wnum}=curW;
        end
    end
end

function[numrows,numcols,newwl]=l_expandCompoundHWidgets(wl)


    numrows=1;
    numcols=length(wl);
    numwidgets=length(wl);

    newwl=cell(1,numwidgets);
    wnum=0;
    for ii=1:numel(wl)
        curW=wl{ii};
        wnum=wnum+1;
        curW.RowSpan=[1,numrows];
        curW.ColSpan=[ii,ii];
        newwl{wnum}=curW;
    end
end




















