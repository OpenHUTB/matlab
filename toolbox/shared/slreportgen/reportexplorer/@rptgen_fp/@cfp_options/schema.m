function schema






    pkg=findpackage('rptgen_fp');
    pkgRG=findpackage('rptgen');

    h=schema.class(pkg,'cfp_options',pkgRG.findclass('rptcomponent'));





    p=rptgen.prop(h,'FixLogPref',{
    '1',getString(message('rptgen:fp_cfp_options:allFixedPointBlocks'))
    '2',getString(message('rptgen:fp_cfp_options:noLogging'))
    '0',getString(message('rptgen:fp_cfp_options:useDologParameter'))
    'obsolete',''
    },'obsolete',getString(message('rptgen:fp_cfp_options:logMinAndMax')));
    p.AccessFlags.Serialize='off';
    p.Visible='off';
    p.setFunction=@setFixLogPref;


    p=rptgen.prop(h,'FixUseDbl',{
    '1',getString(message('rptgen:fp_cfp_options:allFixedPointBlocks'))
    '2',getString(message('rptgen:fp_cfp_options:noDoubles'))
    '0',getString(message('rptgen:fp_cfp_options:useDblOverParameter'))
    'obsolete',''
    },'obsolete',getString(message('rptgen:fp_cfp_options:doublesOverride')));
    p.AccessFlags.Serialize='off';
    p.Visible='off';
    p.setFunction=@setFixUseDbl;


    p=rptgen.prop(h,'FixLogMerge',{
    '0',getString(message('rptgen:fp_cfp_options:overrideLog'))
    '1',getString(message('rptgen:fp_cfp_options:mergeLog'))
    'obsolete',''
    },'obsolete',getString(message('rptgen:fp_cfp_options:logMode')));
    p.AccessFlags.Serialize='off';
    p.Visible='off';
    p.setFunction=@setFixLogMerge;



    rptgen.prop(h,'DataTypeOverride',{
    'UseLocalSettings',getString(message('rptgen:fp_cfp_options:useLocalSettings'))
    'ScaledDoubles',getString(message('rptgen:fp_cfp_options:scaledDoubles'))
    'TrueDoubles',getString(message('rptgen:fp_cfp_options:trueDoubles'))
    'TrueSingles',getString(message('rptgen:fp_cfp_options:trueSingles'))
    'ForceOff',getString(message('rptgen:fp_cfp_options:forceOff'))
    },'UseLocalSettings',getString(message('rptgen:fp_cfp_options:dataTypeOverride')));



    rptgen.prop(h,'MinMaxOverflowLogging',{
    'UseLocalSettings',getString(message('rptgen:fp_cfp_options:useLocalSettings'))
    'MinMaxAndOverflow',getString(message('rptgen:fp_cfp_options:minMaxOverflow'))
    'OverflowOnly',getString(message('rptgen:fp_cfp_options:overflowOnly'))
    'ForceOff',getString(message('rptgen:fp_cfp_options:forceOff'))
    },'UseLocalSettings',getString(message('rptgen:fp_cfp_options:instrumentationMode')));



    rptgen.prop(h,'MinMaxOverflowArchiveMode',{
    'Overwrite',getString(message('rptgen:fp_cfp_options:overwriteLog'))
    'Merge',getString(message('rptgen:fp_cfp_options:mergeLog'))
    },'Overwrite',getString(message('rptgen:fp_cfp_options:loggingType')));


    rptgen.makeStaticMethods(h,{
    },{
    });


    function valueStored=setFixLogMerge(this,valueProposed)




        switch valueProposed
        case '0'
            this.MinMaxOverflowArchiveMode='Overwrite';

        case '1'
            this.MinMaxOverflowArchiveMode='Merge';


        end
        valueStored='obsolete';


        function valueStored=setFixUseDbl(this,valueProposed)




            switch valueProposed
            case '1'
                this.DataTypeOverride='TrueDoubles';

            case '2'
                this.DataTypeOverride='ForceOff';

            case '0'
                this.DataTypeOverride='UseLocalSettings';


            end
            valueStored='obsolete';


            function valueStored=setFixLogPref(this,valueProposed)




                switch valueProposed
                case '1'
                    this.MinMaxOverflowLogging='MinMaxAndOverflow';

                case '2'
                    this.MinMaxOverflowLogging='ForceOff';

                case '0'
                    this.MinMaxOverflowLogging='UseLocalSettings';


                end
                valueStored='obsolete';


