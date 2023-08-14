function schema=getContentOptionsSchema(dlgsrc,name)%#ok<INUSD>











    tag_prefix='sdd_';

    pnlContentOptions.Type='panel';
    pnlContentOptions.Tag=[tag_prefix,'OutputFormatPanel'];



    schema=pnlContentOptions;

end
