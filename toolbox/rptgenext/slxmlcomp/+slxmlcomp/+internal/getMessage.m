function message=getMessage(key,varargin)
















    locale=java.util.Locale.getDefault();
    loader=java.lang.ClassLoader.getSystemClassLoader();
    resourcePath='com.mathworks.toolbox.rptgenslxmlcomp.gui.resources.RES_gui';
    bundle=java.util.ResourceBundle.getBundle(resourcePath,locale,loader);
    if numel(varargin)>0
        message=char(java.text.MessageFormat.format(bundle.getString(key),varargin));
    else
        message=char(bundle.getString(key));
    end
end
