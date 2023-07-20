function newspecs=setcurrentspecs(this,newspecs)





    checkoutfdtbxlicense(this);


    oldspecs=this.CurrentSpecs;


    rmprops(this,oldspecs);

    if isempty(newspecs)
        return;
    end

    syncspecs(this,newspecs);


    addprops(this,newspecs);

    P=findprop(newspecs,'NBands');
    if~isempty(P)
        l=event.proplistener(newspecs,P,'PostSet',...
        @(~,e)band_listener(this,e));
        this.BandListener=l;
    end

    P=findprop(newspecs,'privConstraints');
    if~isempty(P)
        l=event.proplistener(newspecs,P,'PostSet',...
        @(~,e)constraint_listener(this,e));
        this.ConstraintListener=l;
    end


    function band_listener(this,eventData)

        hfspecs=eventData.AffectedObject;

        notify(this,'FaceChanging');

        actualNBands=hfspecs.NBands;
        hfspecs.NBands=10;
        rmprops(this,hfspecs);

        hfspecs.NBands=actualNBands;
        addprops(this,hfspecs);
        notify(this,'FaceChanged');

        function constraint_listener(this,eventData)

            hfspecs=eventData.AffectedObject;
            notify(this,'FaceChanging');

            for idx=1:10
                propNames{idx}=sprintf('%s%d%s','B',idx,'Ripple');%#ok<*AGROW>
            end
            rmprops(this,propNames{:});


            cnt=1;
            propNames={};
            for idx=1:hfspecs.NBands
                if hfspecs.(sprintf('%s%d%s','B',idx,'Constrained'))
                    propNames{cnt}=sprintf('%s%d%s','B',idx,'Ripple');
                    cnt=cnt+1;
                end
            end
            if~isempty(propNames)
                addprops(this,hfspecs,propNames{:});
            end
            notify(this,'FaceChanged');


