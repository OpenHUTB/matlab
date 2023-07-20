function dlg=createDialog(obj,Parent,props,uicomp,dlgName,values)



    error1=[
    219,219,219,225,219,219,219,219,219,219,219,219,219,219
    219,219,219,219,219,219,219,219,219,219,219,226,219,219
    219,219,219,219,219,219,255,255,219,219,219,219,226,219
    219,219,219,219,219,219,255,255,219,219,219,219,219,219
    219,219,219,219,219,219,255,255,219,219,219,219,219,224
    219,219,219,219,219,219,255,255,219,219,219,219,219,219
    219,219,219,219,219,219,255,255,219,219,219,219,219,219
    219,219,219,219,219,219,255,255,219,219,219,219,219,219
    219,219,219,219,219,219,219,219,219,219,219,219,219,219
    219,219,219,219,219,219,255,255,219,219,219,219,219,219
    219,219,219,219,219,219,219,219,219,219,219,219,219,219
    219,219,219,217,219,219,219,219,219,219,219,219,219,219
    219,219,219,219,219,219,219,219,219,219,219,219,219,219];


    error2=[
    60,60,60,60,60,60,60,60,60,60,60,60,60,60
    60,60,60,60,60,60,60,60,60,60,60,60,60,60
    60,60,60,60,60,60,255,255,60,60,60,60,60,60
    60,60,60,60,60,60,255,255,60,60,60,60,60,60
    60,60,60,60,60,60,255,255,60,60,60,60,60,60
    60,60,60,60,60,60,255,255,60,60,60,60,60,60
    60,60,60,60,60,60,255,255,60,60,60,60,60,60
    60,60,60,60,60,60,255,255,60,60,60,60,60,60
    60,60,60,60,60,60,60,60,60,60,60,60,60,60
    60,60,60,60,60,60,255,255,60,60,60,60,60,60
    60,60,60,60,60,60,60,60,60,60,60,60,60,60
    60,60,60,60,60,60,60,60,60,60,60,60,60,60
    60,60,60,60,60,60,60,60,60,60,60,60,60,60];


    error3=[
    48,48,48,48,48,48,48,48,48,48,48,48,48,48
    48,48,48,48,48,48,48,48,48,48,48,48,48,48
    48,48,48,48,48,48,255,255,48,48,48,48,48,48
    48,48,48,48,48,48,255,255,48,48,48,48,48,48
    48,48,48,48,48,48,255,255,48,48,48,48,48,48
    48,48,48,48,48,48,255,255,48,48,48,48,48,48
    48,48,48,48,48,48,255,255,48,48,48,48,48,48
    48,48,48,48,48,48,255,255,48,48,48,48,48,48
    48,48,48,48,48,48,48,48,48,48,48,48,48,48
    48,48,48,48,48,48,255,255,48,48,48,48,48,48
    48,48,48,48,48,48,48,48,48,48,48,48,48,48
    48,48,48,48,48,48,48,48,48,48,48,48,48,48
    48,48,48,48,48,48,48,48,48,48,48,48,48,48];
    ErrorCData=zeros(13,14,3,'uint8');
    ErrorCData(:,:,1)=error1;
    ErrorCData(:,:,2)=error2;
    ErrorCData(:,:,3)=error3;
    dlg=uigridlayout(Parent);
    for j=1:numel(props)
        lab=uilabel('Parent',dlg,'Text',props{j},'Tag',[props{j},'Label'],'horizontalAlignment','right');
        setPosition(lab,j,1);
    end

    for i=1:numel(props)
        if isnumeric(values{i})
            val=mat2str(values{i});
        elseif strcmpi(class(values{i}),'function_handle')
            val=func2str(values{i});
        elseif islogical(values{i})
            val=values{i};
        else
            val=values{i};
        end

        if isempty(val)
            val='';
        end
        switch uicomp{i}
        case 'uilabel'
            l=uilabel('Parent',dlg,'Text',val,'Tag',props{i});
            setPosition(l,i,3);
        case 'uieditfield'
            l=uieditfield('Parent',dlg,'Tag',props{i},'ValueChangedFcn',@(src,evt)obj.valuechanged(src,evt),'Value',val);
            setPosition(l,i,3);
        case 'edit'
            im=uiimage('Parent',dlg,'Tag',props{i},'ImageSource',ErrorCData,'Visible','off');
            setPosition(im,i,2);
            try
                e=uieditfield('Parent',dlg,'Tag',props{i},'ValueChangedFcn',...
                @(src,evt)obj.valuechanged(src,evt),'Value',val);
            catch me
                if islogical(val)
                    im.delete;
                    e=uicheckbox('Parent',dlg,'Tag',props{i},'value',val,'Text','','ValueChangedFcn',...
                    @(src,evt)obj.valuechanged(src,evt));
                end
            end
            setPosition(e,i,3);
        case 'image'
            im=uiimage('Parent',dlg,'Tag',props{i},'ImageSource',ErrorCData,'Visible','off');
            setPosition(im,i,2);
        case 'dropdown'
            d=uidropdown('Parent',dlg,'Items',val{1},'Value',val{2},'Tag',props{i},'ValueChangedFcn',...
            @(src,evt)obj.valuechanged(src,evt));
            setPosition(d,i,3);
        case 'button'
            b=uibutton('Parent',dlg,'Tag',props{i});
            setPosition(b,i,3);
        case 'tree'
            t=uitree('Parent',dlg,'Tag',props{i});
            setPosition(t,i,1);
        case 'textarea'
            ta=uitextarea('Parent',dlg,'Tag',props{i});
            setPosition(ta,i,1);
        case 'table'
            tab=uitable('Parent',dlg,'Tag',props{i});
            setPosition(tab,i,1);
        case 'checkbox'
            val=logical(val);
            tab=uicheckbox('Parent',dlg,'Tag',props{i},'value',val,'Text','','ValueChangedFcn',...
            @(src,evt)obj.valuechanged(src,evt));
            setPosition(tab,i,3);
        end
    end
    dlg.RowHeight=ones(1,numel(props)).*25;
    dlg.ColumnWidth={150,16,90,'fit'};
    dlg.Scrollable='on';







end



function setPosition(gobj,row,column)
    gobj.Layout.Row=row;
    gobj.Layout.Column=column;
end