function sNew=dlgAddPanel(sOrig,varargin)












    addCount=length(varargin);

    sNew=struct('LayoutGrid',[addCount+1,1],...
    'ColStretch',[1],...
    'RowStretch',[1],...
    'Items',[]);

    if isfield(sOrig,'DialogTitle')


        sOrig.Type='panel';




        promoteProps={
'StandaloneButtonSet'
'EmbeddedButtonSet'
'DialogTitle'
'DialogTag'
'ExplicitShow'
'SmartApply'
'HelpMethod'
'HelpArgs'
'CloseCallback'
'CloseArgs'
'CloseMethod'
'CloseMethodArgs'
'CloseMethodArgsDT'
'PreApplyCallback'
'PreApplyMethod'
'PreApplyArgs'
'PreApplyArgsDT'
        };









        for i=1:length(promoteProps)
            if isfield(sOrig,promoteProps{i})
                sNew.(promoteProps{i})=sOrig.(promoteProps{i});
                sOrig=rmfield(sOrig,promoteProps{i});
            end
        end
    else
        sNew.Type='panel';
    end






    rowStretch=[];
    for i=1:addCount
        varargin{i}.ColSpan=[1,1];
        varargin{i}.RowSpan=[i,i];
        rowStretch(1,i)=0;
    end
    rowStretch(1,addCount+1)=1;
    sNew.RowStretch=rowStretch;

    sOrig.ColSpan=[1,1];
    sOrig.RowSpan=[addCount+1,addCount+1];

    varargin{end+1}=sOrig;
    sNew.Items=varargin;

