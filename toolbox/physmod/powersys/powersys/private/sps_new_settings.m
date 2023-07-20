function setblk=sps_new_settings(varargin)




    setblk=false;

    if~isempty(varargin)
        if any(ismember({'_init','_cback'},varargin{1}))
            setblk=true;
            maskVis=get_param(gcbh,'MaskVisibilities');
            maskVis(:)={'off'};
            set_param(gcbh,'MaskVisibilities',maskVis);
            maskDesc=sprintf('This block is obsolete. Delete this block from your model.\n\nFor information on optimizing solver and powergui settings, visit powergui block documentation.');
            set_param(gcbh,'MaskDescription',maskDesc);



            iconDisp=sprintf('color(''red''); disp(''Obsolete block.\\n Delete it from your model.'')');
            set_param(gcbh,'MaskDisplay',iconDisp);


            if strcmp(varargin{1},'_init')
                warning(message('physmod:powersys:library:ObsoleteSPSSTAssistant',getfullname(gcbh)));
            end
        end
    end