function this=ConfigComp()



    this=SlCovCC.ConfigComp('Simulink Coverage');

    this.Description='Simulink Coverage Configuration Component';

    propsavtcc=find(this.classhandle.properties,'accessflags.publicset',...
    'on','accessflags.publicget','on','visible','on');
    L(1)=handle.listener(this,propsavtcc,'PropertyPostSet',@propertyChanged);
    L(1).CallbackTarget=this;
    this.slcovccListener=L;


    this.loadComponentDataModel;
