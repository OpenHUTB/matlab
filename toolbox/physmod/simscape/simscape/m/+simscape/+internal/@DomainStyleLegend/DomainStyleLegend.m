classdef DomainStyleLegend<handle


    properties(Access=private)
        Label='';
        Dialog=[];
        TagPrefix='SimscapeLineStylesLegend';
    end

    methods

        function obj=DomainStyleLegend(label)
            if nargin==0
                label='';
            end
            obj.Label=label;
        end

        function show(this)
            if isempty(this.Dialog)
                this.Dialog=DAStudio.Dialog(this);
            else
                this.Dialog.show;
            end
        end

        function schema=getDialogSchema(this)
            schema.DialogTitle=getString(message(...
            'physmod:simscape:simscape:domainlegend:DialogTitle'));
            schema.DialogTag=[this.TagPrefix,'Dialog'];
            schema.EmbeddedButtonSet={'Help'};
            schema.StandaloneButtonSet={'Help'};
            schema.CloseCallback='simscape.internal.DomainStyleLegend.close';
            schema.CloseArgs={this};
            schema.HelpMethod='helpview';
            schema.HelpArgs={'simscape','DomainLineStyles'};
            panel.Type='panel';
            panel.LayoutGrid=[1,1];
            panel.Items={createTab(this)};
            panel.BackgroundColor=[255,255,255];
            schema.Items={panel};
        end

    end

    methods(Access=private)
        function main=createTab(this)

            [~,styles]=builtin('_simscape_current_stylesheet');

            main.Type='panel';
            main.Name='';
            main.BackgroundColor=[255,255,255];
            main.Tag='';
            itemIdx=0;

            numStyles=numel(styles);
            numCols=6;

            colorColSpan=[2,2];
            styleColSpan=[3,3];
            labelColSpan=[5,5];
            domainColSpan=[4,4];

            headerRowSpan=2;

            colorHeading.Type='text';
            colorHeading.Bold=true;
            colorHeading.Name=getString(message(...
            'physmod:simscape:simscape:domainlegend:ColorColumnTitle'));
            colorHeading.ColSpan=colorColSpan;
            colorHeading.RowSpan=[headerRowSpan,headerRowSpan];
            colorHeading.Tag=[this.TagPrefix,'ColorHeading'];
            colorHeading.Visible=true;

            styleHeading.Type='text';
            styleHeading.Bold=true;
            styleHeading.Name='Style';
            styleHeading.ColSpan=styleColSpan;
            styleHeading.RowSpan=[headerRowSpan,headerRowSpan];
            styleHeading.Tag=[this.TagPrefix,'StyleHeading'];
            styleHeading.Visible=false;

            labelHeading.Type='text';
            labelHeading.Bold=true;
            labelHeading.Name=getString(message(...
            'physmod:simscape:simscape:domainlegend:PathColumnTitle'));
            labelHeading.ColSpan=labelColSpan;
            labelHeading.RowSpan=[headerRowSpan,headerRowSpan];
            labelHeading.Tag=[this.TagPrefix,'PathHeading'];
            labelHeading.Visible=true;

            domainHeading.Type='text';
            domainHeading.Bold=true;
            domainHeading.Name=getString(message(...
            'physmod:simscape:simscape:domainlegend:NameColumnTitle'));
            domainHeading.ColSpan=domainColSpan;
            domainHeading.RowSpan=[headerRowSpan,headerRowSpan];
            domainHeading.Tag=[this.TagPrefix,'DomainHeading'];
            domainHeading.Visible=true;

            itemIdx=itemIdx+1;
            main.Items{itemIdx}=colorHeading;

            itemIdx=itemIdx+1;
            main.Items{itemIdx}=styleHeading;

            itemIdx=itemIdx+1;
            main.Items{itemIdx}=labelHeading;

            itemIdx=itemIdx+1;
            main.Items{itemIdx}=domainHeading;

            itemRow=3;
            tagIndexOffset=itemRow-1;
            for idx=1:numStyles

                tagIndex=int2str(itemRow-tagIndexOffset);
                domainName=styles(idx).Name;


                validDomainExtensions={'.ssc','.sscp'};
                domainPath=strrep(styles(idx).Name,'network_engine_domain.','');
                filePath=which(domainPath);
                [fileDir,fileName,fileExt]=fileparts(filePath);
                isSimscapeFile=any(strcmp(fileExt,validDomainExtensions));

                isEditable=false;
                if isSimscapeFile&&exist(filePath,'file')
                    try

                        d=feval(domainPath,simscape.FileDispatchReturnAs.Classic);

                        if strcmp(d.item_type,'domain')
                            domainDescription=d.descriptor;
                        else

                            continue;
                        end
                    catch

                        continue;
                    end
                    isEditable=exist(...
                    fullfile(fileDir,[fileName,'.ssc']),'file');
                    if isEditable

                        domainToolTip=getToolTip('editable');
                    else

                        domainToolTip=getToolTip('protected');
                    end
                else
                    domainToolTip=getToolTip('builtin');
                    if strcmp(domainName,'network_engine_domain.output')
                        domainDescription=getString(message(...
                        'physmod:simscape:simscape:domainlegend:PhysicalSignalsName'));
                        domainPath='-';
                    elseif lIsSmPort(domainName)
                        [~,domainDescription]=lIsSmPort(domainName);
                        domainPath='-';
                    else

                        continue;
                    end
                end

                color.Type='text';
                color.Name='';
                color.BackgroundColor=styles(idx).Color'*255;
                color.ColSpan=colorColSpan;
                color.RowSpan=[itemRow,itemRow];
                color.Visible=colorHeading.Visible;
                color.Tag=[this.TagPrefix,'Colors',tagIndex];

                itemIdx=itemIdx+1;
                main.Items{itemIdx}=color;

                style.Type='text';
                if styles(idx).Stroke
                    style.Name='Solid line';
                else
                    style.Name='Dash line';
                end
                style.Name=styles(idx).Stroke;
                style.ColSpan=styleColSpan;
                style.RowSpan=[itemRow,itemRow];
                style.Alignment=6;
                style.Visible=styleHeading.Visible;
                style.Tag=[this.TagPrefix,'Styles',tagIndex];

                itemIdx=itemIdx+1;
                main.Items{itemIdx}=style;

                domain.Type='text';
                domain.Name=domainDescription;
                domain.ColSpan=domainColSpan;
                domain.RowSpan=[itemRow,itemRow];
                domain.Visible=domainHeading.Visible;
                domain.Tag=[this.TagPrefix,'Domains',tagIndex];

                itemIdx=itemIdx+1;
                main.Items{itemIdx}=domain;

                label='';
                if isEditable
                    label.Type='hyperlink';
                    label.MatlabMethod='simscape.internal.DomainStyleLegend.openSource';
                    label.MatlabArgs={domainPath};
                else
                    label.Type='text';
                end
                label.Name=domainPath;
                label.ColSpan=labelColSpan;
                label.RowSpan=[itemRow,itemRow];
                label.Visible=labelHeading.Visible;
                label.Tag=[this.TagPrefix,'Labels',tagIndex];
                label.ToolTip=domainToolTip;

                itemIdx=itemIdx+1;
                main.Items{itemIdx}=label;

                itemRow=itemRow+1;
            end

            leftSpacer.Type='panel';
            leftSpacer.ColSpan=[1,1];
            leftSpacer.RowSpan=[1,itemRow];

            itemIdx=itemIdx+1;
            main.Items{itemIdx}=leftSpacer;

            rightSpacer.Type='panel';
            rightSpacer.ColSpan=[numCols,numCols];
            rightSpacer.RowSpan=[1,itemRow];

            itemIdx=itemIdx+1;
            main.Items{itemIdx}=rightSpacer;

            topSpacer.Type='panel';
            topSpacer.ColSpan=[2,numCols-1];
            topSpacer.RowSpan=[1,1];

            itemIdx=itemIdx+1;
            main.Items{itemIdx}=topSpacer;

            bottomSpacer.Type='panel';
            bottomSpacer.ColSpan=[2,numCols-1];
            bottomSpacer.RowSpan=[itemRow,itemRow];

            itemIdx=itemIdx+1;
            main.Items{itemIdx}=bottomSpacer;

            main.LayoutGrid=[itemRow,numCols];
        end
    end

    methods(Static)
        function close(obj)
            obj.Dialog=[];
        end

        function openSource(d)
            edit(d);
        end

    end

end

function[r,str]=lIsSmPort(s)

    r=true;
    if strcmp(s,'network_engine_domain.simmechanics.connections.frame')
        type='Mechanical3dFrameName';
    elseif strcmp(s,'network_engine_domain.simmechanics.connections.geometry')
        type='Mechanical3dGeometryName';
    elseif strcmp(s,'network_engine_domain.simmechanics.connections.beltcable')
        type='Mechanical3dBeltCableName';
    else
        r=false;
    end

    if(r)
        str=getString(message(...
        ['physmod:simscape:simscape:domainlegend:',type]));
    end
end

function toolTip=getToolTip(domainType)
    switch domainType
    case 'editable'
        type='OpenSourceTooltip';
    case 'protected'
        type='ProtectedSourceTooltip';
    case 'builtin'
        type='BuiltinTooltip';
    otherwise
        type='InvalidDomainTooltip';
    end
    toolTip=getString(message(...
    ['physmod:simscape:simscape:domainlegend:',type]));
end