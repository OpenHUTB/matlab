// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   DownloadServiceStub.java

package com.mathworks.internal.dws.client.v3;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.rmi.RemoteException;
import java.util.*;
import javax.xml.namespace.QName;
import org.apache.axiom.om.*;
import org.apache.axiom.soap.*;
import org.apache.axis2.AxisFault;
import org.apache.axis2.addressing.EndpointReference;
import org.apache.axis2.client.*;
import org.apache.axis2.context.*;
import org.apache.axis2.databinding.ADBException;
import org.apache.axis2.description.*;
import org.apache.axis2.transport.TransportSender;

// Referenced classes of package com.mathworks.internal.dws.client.v3:
//            GetUpdatedSoftwareWithinReleaseAndArchResponse, GetUpdatedSoftwareWithinPasscodeAndArchResponse, GetSoftwareProductInfoByLicenseAndArchitecturesResponse, PingResponse, 
//            GetUpdatedSoftwareWithinReleaseResponse, GetAllUpdatedSoftwareResponse, GetUpdatedSoftwareWithinReleaseAndArch, GetUpdatedSoftwareWithinPasscodeAndArch, 
//            GetSoftwareProductInfoByLicenseAndArchitectures, Ping, GetUpdatedSoftwareWithinRelease, GetAllUpdatedSoftware, 
//            DownloadService, BitVer, GetUpdatedSoftwareWithinReleaseAndArchReturn, GetUpdatedSoftwareWithinPasscodeAndArchReturn, 
//            GetSoftwareProductInfoByLicenseAndArchitecturesReturn, GetUpdatedSoftwareWithinReleaseReturn, GetAllUpdatedSoftwareReturn

public class DownloadServiceStub extends Stub
    implements DownloadService
{

    private static synchronized String getUniqueSuffix()
    {
        if(counter > 0x1869f)
            counter = 0;
        counter++;
        return (new StringBuilder()).append(Long.toString(System.currentTimeMillis())).append("_").append(counter).toString();
    }

    private void populateAxisService()
        throws AxisFault
    {
        _service = new AxisService((new StringBuilder()).append("DownloadService").append(getUniqueSuffix()).toString());
        addAnonymousOperations();
        _operations = new AxisOperation[6];
        AxisOperation __operation = new OutInAxisOperation();
        __operation.setName(new QName("https://services.mathworks.com/dws3/services/DownloadService", "getUpdatedSoftwareWithinReleaseAndArch"));
        _service.addOperation(__operation);
        _operations[0] = __operation;
        __operation = new OutInAxisOperation();
        __operation.setName(new QName("https://services.mathworks.com/dws3/services/DownloadService", "getUpdatedSoftwareWithinPasscodeAndArch"));
        _service.addOperation(__operation);
        _operations[1] = __operation;
        __operation = new OutInAxisOperation();
        __operation.setName(new QName("https://services.mathworks.com/dws3/services/DownloadService", "getSoftwareProductInfoByLicenseAndArchitectures"));
        _service.addOperation(__operation);
        _operations[2] = __operation;
        __operation = new OutInAxisOperation();
        __operation.setName(new QName("https://services.mathworks.com/dws3/services/DownloadService", "ping"));
        _service.addOperation(__operation);
        _operations[3] = __operation;
        __operation = new OutInAxisOperation();
        __operation.setName(new QName("https://services.mathworks.com/dws3/services/DownloadService", "getUpdatedSoftwareWithinRelease"));
        _service.addOperation(__operation);
        _operations[4] = __operation;
        __operation = new OutInAxisOperation();
        __operation.setName(new QName("https://services.mathworks.com/dws3/services/DownloadService", "getAllUpdatedSoftware"));
        _service.addOperation(__operation);
        _operations[5] = __operation;
    }

    private void populateFaults()
    {
    }

    public DownloadServiceStub(ConfigurationContext configurationContext, String targetEndpoint)
        throws AxisFault
    {
        this(configurationContext, targetEndpoint, false);
    }

    public DownloadServiceStub(ConfigurationContext configurationContext, String targetEndpoint, boolean useSeparateListener)
        throws AxisFault
    {
        faultExceptionNameMap = new HashMap();
        faultExceptionClassNameMap = new HashMap();
        faultMessageMap = new HashMap();
        opNameArray = null;
        populateAxisService();
        populateFaults();
        _serviceClient = new ServiceClient(configurationContext, _service);
        configurationContext = _serviceClient.getServiceContext().getConfigurationContext();
        _serviceClient.getOptions().setTo(new EndpointReference(targetEndpoint));
        _serviceClient.getOptions().setUseSeparateListener(useSeparateListener);
    }

    public DownloadServiceStub(ConfigurationContext configurationContext)
        throws AxisFault
    {
        this(configurationContext, "https://dws.mathworks.com/dws3/services/DownloadService");
    }

    public DownloadServiceStub()
        throws AxisFault
    {
        this("https://dws.mathworks.com/dws3/services/DownloadService");
    }

    public DownloadServiceStub(String targetEndpoint)
        throws AxisFault
    {
        this(null, targetEndpoint);
    }

    public GetUpdatedSoftwareWithinReleaseAndArchReturn getUpdatedSoftwareWithinReleaseAndArch(String release16, BitVer products17[], String architecture18, String clientString19, String locale20)
        throws RemoteException
    {
        MessageContext _messageContext = null;
        GetUpdatedSoftwareWithinReleaseAndArchReturn getupdatedsoftwarewithinreleaseandarchreturn;
        try
        {
            OperationClient _operationClient = _serviceClient.createClient(_operations[0].getName());
            _operationClient.getOptions().setAction("\"\"");
            _operationClient.getOptions().setExceptionToBeThrownOnSOAPFault(true);
            addPropertyToOperationClient(_operationClient, "whttp:queryParameterSeparator", "&");
            _messageContext = new MessageContext();
            SOAPEnvelope env = null;
            GetUpdatedSoftwareWithinReleaseAndArch dummyWrappedType = null;
            env = toEnvelope(getFactory(_operationClient.getOptions().getSoapVersionURI()), release16, products17, architecture18, clientString19, locale20, dummyWrappedType, optimizeContent(new QName("https://services.mathworks.com/dws3/services/DownloadService", "getUpdatedSoftwareWithinReleaseAndArch")));
            _serviceClient.addHeadersToEnvelope(env);
            _messageContext.setEnvelope(env);
            _operationClient.addMessageContext(_messageContext);
            _operationClient.execute(true);
            MessageContext _returnMessageContext = _operationClient.getMessageContext("In");
            SOAPEnvelope _returnEnv = _returnMessageContext.getEnvelope();
            Object object = fromOM(_returnEnv.getBody().getFirstElement(), com/mathworks/internal/dws/client/v3/GetUpdatedSoftwareWithinReleaseAndArchResponse, getEnvelopeNamespaces(_returnEnv));
            getupdatedsoftwarewithinreleaseandarchreturn = getGetUpdatedSoftwareWithinReleaseAndArchResponseResponse((GetUpdatedSoftwareWithinReleaseAndArchResponse)object);
        }
        catch(AxisFault f)
        {
            OMElement faultElt = f.getDetail();
            if(faultElt != null)
            {
                if(faultExceptionNameMap.containsKey(faultElt.getQName()))
                    try
                    {
                        String exceptionClassName = (String)faultExceptionClassNameMap.get(faultElt.getQName());
                        Class exceptionClass = Class.forName(exceptionClassName);
                        Exception ex = (Exception)exceptionClass.newInstance();
                        String messageClassName = (String)faultMessageMap.get(faultElt.getQName());
                        Class messageClass = Class.forName(messageClassName);
                        Object messageObject = fromOM(faultElt, messageClass, null);
                        Method m = exceptionClass.getMethod("setFaultMessage", new Class[] {
                            messageClass
                        });
                        m.invoke(ex, new Object[] {
                            messageObject
                        });
                        throw new RemoteException(ex.getMessage(), ex);
                    }
                    catch(ClassCastException e)
                    {
                        throw f;
                    }
                    catch(ClassNotFoundException e)
                    {
                        throw f;
                    }
                    catch(NoSuchMethodException e)
                    {
                        throw f;
                    }
                    catch(InvocationTargetException e)
                    {
                        throw f;
                    }
                    catch(IllegalAccessException e)
                    {
                        throw f;
                    }
                    catch(InstantiationException e)
                    {
                        throw f;
                    }
                else
                    throw f;
            } else
            {
                throw f;
            }
        }
        _messageContext.getTransportOut().getSender().cleanup(_messageContext);
        return getupdatedsoftwarewithinreleaseandarchreturn;
        Exception exception;
        exception;
        _messageContext.getTransportOut().getSender().cleanup(_messageContext);
        throw exception;
    }

    public GetUpdatedSoftwareWithinPasscodeAndArchReturn getUpdatedSoftwareWithinPasscodeAndArch(BitVer bv24[], String architecture25, String clientString26, String locale27)
        throws RemoteException
    {
        MessageContext _messageContext = null;
        GetUpdatedSoftwareWithinPasscodeAndArchReturn getupdatedsoftwarewithinpasscodeandarchreturn;
        try
        {
            OperationClient _operationClient = _serviceClient.createClient(_operations[1].getName());
            _operationClient.getOptions().setAction("\"\"");
            _operationClient.getOptions().setExceptionToBeThrownOnSOAPFault(true);
            addPropertyToOperationClient(_operationClient, "whttp:queryParameterSeparator", "&");
            _messageContext = new MessageContext();
            SOAPEnvelope env = null;
            GetUpdatedSoftwareWithinPasscodeAndArch dummyWrappedType = null;
            env = toEnvelope(getFactory(_operationClient.getOptions().getSoapVersionURI()), bv24, architecture25, clientString26, locale27, dummyWrappedType, optimizeContent(new QName("https://services.mathworks.com/dws3/services/DownloadService", "getUpdatedSoftwareWithinPasscodeAndArch")));
            _serviceClient.addHeadersToEnvelope(env);
            _messageContext.setEnvelope(env);
            _operationClient.addMessageContext(_messageContext);
            _operationClient.execute(true);
            MessageContext _returnMessageContext = _operationClient.getMessageContext("In");
            SOAPEnvelope _returnEnv = _returnMessageContext.getEnvelope();
            Object object = fromOM(_returnEnv.getBody().getFirstElement(), com/mathworks/internal/dws/client/v3/GetUpdatedSoftwareWithinPasscodeAndArchResponse, getEnvelopeNamespaces(_returnEnv));
            getupdatedsoftwarewithinpasscodeandarchreturn = getGetUpdatedSoftwareWithinPasscodeAndArchResponseResponse((GetUpdatedSoftwareWithinPasscodeAndArchResponse)object);
        }
        catch(AxisFault f)
        {
            OMElement faultElt = f.getDetail();
            if(faultElt != null)
            {
                if(faultExceptionNameMap.containsKey(faultElt.getQName()))
                    try
                    {
                        String exceptionClassName = (String)faultExceptionClassNameMap.get(faultElt.getQName());
                        Class exceptionClass = Class.forName(exceptionClassName);
                        Exception ex = (Exception)exceptionClass.newInstance();
                        String messageClassName = (String)faultMessageMap.get(faultElt.getQName());
                        Class messageClass = Class.forName(messageClassName);
                        Object messageObject = fromOM(faultElt, messageClass, null);
                        Method m = exceptionClass.getMethod("setFaultMessage", new Class[] {
                            messageClass
                        });
                        m.invoke(ex, new Object[] {
                            messageObject
                        });
                        throw new RemoteException(ex.getMessage(), ex);
                    }
                    catch(ClassCastException e)
                    {
                        throw f;
                    }
                    catch(ClassNotFoundException e)
                    {
                        throw f;
                    }
                    catch(NoSuchMethodException e)
                    {
                        throw f;
                    }
                    catch(InvocationTargetException e)
                    {
                        throw f;
                    }
                    catch(IllegalAccessException e)
                    {
                        throw f;
                    }
                    catch(InstantiationException e)
                    {
                        throw f;
                    }
                else
                    throw f;
            } else
            {
                throw f;
            }
        }
        _messageContext.getTransportOut().getSender().cleanup(_messageContext);
        return getupdatedsoftwarewithinpasscodeandarchreturn;
        Exception exception;
        exception;
        _messageContext.getTransportOut().getSender().cleanup(_messageContext);
        throw exception;
    }

    public GetSoftwareProductInfoByLicenseAndArchitecturesReturn getSoftwareProductInfoByLicenseAndArchitectures(String securityToken31, String release32, String licenseId33, String requestedArchitectures34[], String clientString35, String locale36)
        throws RemoteException
    {
        MessageContext _messageContext = null;
        GetSoftwareProductInfoByLicenseAndArchitecturesReturn getsoftwareproductinfobylicenseandarchitecturesreturn;
        try
        {
            OperationClient _operationClient = _serviceClient.createClient(_operations[2].getName());
            _operationClient.getOptions().setAction("\"\"");
            _operationClient.getOptions().setExceptionToBeThrownOnSOAPFault(true);
            addPropertyToOperationClient(_operationClient, "whttp:queryParameterSeparator", "&");
            _messageContext = new MessageContext();
            SOAPEnvelope env = null;
            GetSoftwareProductInfoByLicenseAndArchitectures dummyWrappedType = null;
            env = toEnvelope(getFactory(_operationClient.getOptions().getSoapVersionURI()), securityToken31, release32, licenseId33, requestedArchitectures34, clientString35, locale36, dummyWrappedType, optimizeContent(new QName("https://services.mathworks.com/dws3/services/DownloadService", "getSoftwareProductInfoByLicenseAndArchitectures")));
            _serviceClient.addHeadersToEnvelope(env);
            _messageContext.setEnvelope(env);
            _operationClient.addMessageContext(_messageContext);
            _operationClient.execute(true);
            MessageContext _returnMessageContext = _operationClient.getMessageContext("In");
            SOAPEnvelope _returnEnv = _returnMessageContext.getEnvelope();
            Object object = fromOM(_returnEnv.getBody().getFirstElement(), com/mathworks/internal/dws/client/v3/GetSoftwareProductInfoByLicenseAndArchitecturesResponse, getEnvelopeNamespaces(_returnEnv));
            getsoftwareproductinfobylicenseandarchitecturesreturn = getGetSoftwareProductInfoByLicenseAndArchitecturesResponseResponse((GetSoftwareProductInfoByLicenseAndArchitecturesResponse)object);
        }
        catch(AxisFault f)
        {
            OMElement faultElt = f.getDetail();
            if(faultElt != null)
            {
                if(faultExceptionNameMap.containsKey(faultElt.getQName()))
                    try
                    {
                        String exceptionClassName = (String)faultExceptionClassNameMap.get(faultElt.getQName());
                        Class exceptionClass = Class.forName(exceptionClassName);
                        Exception ex = (Exception)exceptionClass.newInstance();
                        String messageClassName = (String)faultMessageMap.get(faultElt.getQName());
                        Class messageClass = Class.forName(messageClassName);
                        Object messageObject = fromOM(faultElt, messageClass, null);
                        Method m = exceptionClass.getMethod("setFaultMessage", new Class[] {
                            messageClass
                        });
                        m.invoke(ex, new Object[] {
                            messageObject
                        });
                        throw new RemoteException(ex.getMessage(), ex);
                    }
                    catch(ClassCastException e)
                    {
                        throw f;
                    }
                    catch(ClassNotFoundException e)
                    {
                        throw f;
                    }
                    catch(NoSuchMethodException e)
                    {
                        throw f;
                    }
                    catch(InvocationTargetException e)
                    {
                        throw f;
                    }
                    catch(IllegalAccessException e)
                    {
                        throw f;
                    }
                    catch(InstantiationException e)
                    {
                        throw f;
                    }
                else
                    throw f;
            } else
            {
                throw f;
            }
        }
        _messageContext.getTransportOut().getSender().cleanup(_messageContext);
        return getsoftwareproductinfobylicenseandarchitecturesreturn;
        Exception exception;
        exception;
        _messageContext.getTransportOut().getSender().cleanup(_messageContext);
        throw exception;
    }

    public String ping(String request40)
        throws RemoteException
    {
        MessageContext _messageContext = null;
        String s;
        try
        {
            OperationClient _operationClient = _serviceClient.createClient(_operations[3].getName());
            _operationClient.getOptions().setAction("\"\"");
            _operationClient.getOptions().setExceptionToBeThrownOnSOAPFault(true);
            addPropertyToOperationClient(_operationClient, "whttp:queryParameterSeparator", "&");
            _messageContext = new MessageContext();
            SOAPEnvelope env = null;
            Ping dummyWrappedType = null;
            env = toEnvelope(getFactory(_operationClient.getOptions().getSoapVersionURI()), request40, dummyWrappedType, optimizeContent(new QName("https://services.mathworks.com/dws3/services/DownloadService", "ping")));
            _serviceClient.addHeadersToEnvelope(env);
            _messageContext.setEnvelope(env);
            _operationClient.addMessageContext(_messageContext);
            _operationClient.execute(true);
            MessageContext _returnMessageContext = _operationClient.getMessageContext("In");
            SOAPEnvelope _returnEnv = _returnMessageContext.getEnvelope();
            Object object = fromOM(_returnEnv.getBody().getFirstElement(), com/mathworks/internal/dws/client/v3/PingResponse, getEnvelopeNamespaces(_returnEnv));
            s = getPingResponsePingReturn((PingResponse)object);
        }
        catch(AxisFault f)
        {
            OMElement faultElt = f.getDetail();
            if(faultElt != null)
            {
                if(faultExceptionNameMap.containsKey(faultElt.getQName()))
                    try
                    {
                        String exceptionClassName = (String)faultExceptionClassNameMap.get(faultElt.getQName());
                        Class exceptionClass = Class.forName(exceptionClassName);
                        Exception ex = (Exception)exceptionClass.newInstance();
                        String messageClassName = (String)faultMessageMap.get(faultElt.getQName());
                        Class messageClass = Class.forName(messageClassName);
                        Object messageObject = fromOM(faultElt, messageClass, null);
                        Method m = exceptionClass.getMethod("setFaultMessage", new Class[] {
                            messageClass
                        });
                        m.invoke(ex, new Object[] {
                            messageObject
                        });
                        throw new RemoteException(ex.getMessage(), ex);
                    }
                    catch(ClassCastException e)
                    {
                        throw f;
                    }
                    catch(ClassNotFoundException e)
                    {
                        throw f;
                    }
                    catch(NoSuchMethodException e)
                    {
                        throw f;
                    }
                    catch(InvocationTargetException e)
                    {
                        throw f;
                    }
                    catch(IllegalAccessException e)
                    {
                        throw f;
                    }
                    catch(InstantiationException e)
                    {
                        throw f;
                    }
                else
                    throw f;
            } else
            {
                throw f;
            }
        }
        _messageContext.getTransportOut().getSender().cleanup(_messageContext);
        return s;
        Exception exception;
        exception;
        _messageContext.getTransportOut().getSender().cleanup(_messageContext);
        throw exception;
    }

    public GetUpdatedSoftwareWithinReleaseReturn getUpdatedSoftwareWithinRelease(BitVer bv44[], String clientString45, String locale46)
        throws RemoteException
    {
        MessageContext _messageContext = null;
        GetUpdatedSoftwareWithinReleaseReturn getupdatedsoftwarewithinreleasereturn;
        try
        {
            OperationClient _operationClient = _serviceClient.createClient(_operations[4].getName());
            _operationClient.getOptions().setAction("\"\"");
            _operationClient.getOptions().setExceptionToBeThrownOnSOAPFault(true);
            addPropertyToOperationClient(_operationClient, "whttp:queryParameterSeparator", "&");
            _messageContext = new MessageContext();
            SOAPEnvelope env = null;
            GetUpdatedSoftwareWithinRelease dummyWrappedType = null;
            env = toEnvelope(getFactory(_operationClient.getOptions().getSoapVersionURI()), bv44, clientString45, locale46, dummyWrappedType, optimizeContent(new QName("https://services.mathworks.com/dws3/services/DownloadService", "getUpdatedSoftwareWithinRelease")));
            _serviceClient.addHeadersToEnvelope(env);
            _messageContext.setEnvelope(env);
            _operationClient.addMessageContext(_messageContext);
            _operationClient.execute(true);
            MessageContext _returnMessageContext = _operationClient.getMessageContext("In");
            SOAPEnvelope _returnEnv = _returnMessageContext.getEnvelope();
            Object object = fromOM(_returnEnv.getBody().getFirstElement(), com/mathworks/internal/dws/client/v3/GetUpdatedSoftwareWithinReleaseResponse, getEnvelopeNamespaces(_returnEnv));
            getupdatedsoftwarewithinreleasereturn = getGetUpdatedSoftwareWithinReleaseResponseResponse((GetUpdatedSoftwareWithinReleaseResponse)object);
        }
        catch(AxisFault f)
        {
            OMElement faultElt = f.getDetail();
            if(faultElt != null)
            {
                if(faultExceptionNameMap.containsKey(faultElt.getQName()))
                    try
                    {
                        String exceptionClassName = (String)faultExceptionClassNameMap.get(faultElt.getQName());
                        Class exceptionClass = Class.forName(exceptionClassName);
                        Exception ex = (Exception)exceptionClass.newInstance();
                        String messageClassName = (String)faultMessageMap.get(faultElt.getQName());
                        Class messageClass = Class.forName(messageClassName);
                        Object messageObject = fromOM(faultElt, messageClass, null);
                        Method m = exceptionClass.getMethod("setFaultMessage", new Class[] {
                            messageClass
                        });
                        m.invoke(ex, new Object[] {
                            messageObject
                        });
                        throw new RemoteException(ex.getMessage(), ex);
                    }
                    catch(ClassCastException e)
                    {
                        throw f;
                    }
                    catch(ClassNotFoundException e)
                    {
                        throw f;
                    }
                    catch(NoSuchMethodException e)
                    {
                        throw f;
                    }
                    catch(InvocationTargetException e)
                    {
                        throw f;
                    }
                    catch(IllegalAccessException e)
                    {
                        throw f;
                    }
                    catch(InstantiationException e)
                    {
                        throw f;
                    }
                else
                    throw f;
            } else
            {
                throw f;
            }
        }
        _messageContext.getTransportOut().getSender().cleanup(_messageContext);
        return getupdatedsoftwarewithinreleasereturn;
        Exception exception;
        exception;
        _messageContext.getTransportOut().getSender().cleanup(_messageContext);
        throw exception;
    }

    public GetAllUpdatedSoftwareReturn getAllUpdatedSoftware(String clientString50, String locale51)
        throws RemoteException
    {
        MessageContext _messageContext = null;
        GetAllUpdatedSoftwareReturn getallupdatedsoftwarereturn;
        try
        {
            OperationClient _operationClient = _serviceClient.createClient(_operations[5].getName());
            _operationClient.getOptions().setAction("\"\"");
            _operationClient.getOptions().setExceptionToBeThrownOnSOAPFault(true);
            addPropertyToOperationClient(_operationClient, "whttp:queryParameterSeparator", "&");
            _messageContext = new MessageContext();
            SOAPEnvelope env = null;
            GetAllUpdatedSoftware dummyWrappedType = null;
            env = toEnvelope(getFactory(_operationClient.getOptions().getSoapVersionURI()), clientString50, locale51, dummyWrappedType, optimizeContent(new QName("https://services.mathworks.com/dws3/services/DownloadService", "getAllUpdatedSoftware")));
            _serviceClient.addHeadersToEnvelope(env);
            _messageContext.setEnvelope(env);
            _operationClient.addMessageContext(_messageContext);
            _operationClient.execute(true);
            MessageContext _returnMessageContext = _operationClient.getMessageContext("In");
            SOAPEnvelope _returnEnv = _returnMessageContext.getEnvelope();
            Object object = fromOM(_returnEnv.getBody().getFirstElement(), com/mathworks/internal/dws/client/v3/GetAllUpdatedSoftwareResponse, getEnvelopeNamespaces(_returnEnv));
            getallupdatedsoftwarereturn = getGetAllUpdatedSoftwareResponseResponse((GetAllUpdatedSoftwareResponse)object);
        }
        catch(AxisFault f)
        {
            OMElement faultElt = f.getDetail();
            if(faultElt != null)
            {
                if(faultExceptionNameMap.containsKey(faultElt.getQName()))
                    try
                    {
                        String exceptionClassName = (String)faultExceptionClassNameMap.get(faultElt.getQName());
                        Class exceptionClass = Class.forName(exceptionClassName);
                        Exception ex = (Exception)exceptionClass.newInstance();
                        String messageClassName = (String)faultMessageMap.get(faultElt.getQName());
                        Class messageClass = Class.forName(messageClassName);
                        Object messageObject = fromOM(faultElt, messageClass, null);
                        Method m = exceptionClass.getMethod("setFaultMessage", new Class[] {
                            messageClass
                        });
                        m.invoke(ex, new Object[] {
                            messageObject
                        });
                        throw new RemoteException(ex.getMessage(), ex);
                    }
                    catch(ClassCastException e)
                    {
                        throw f;
                    }
                    catch(ClassNotFoundException e)
                    {
                        throw f;
                    }
                    catch(NoSuchMethodException e)
                    {
                        throw f;
                    }
                    catch(InvocationTargetException e)
                    {
                        throw f;
                    }
                    catch(IllegalAccessException e)
                    {
                        throw f;
                    }
                    catch(InstantiationException e)
                    {
                        throw f;
                    }
                else
                    throw f;
            } else
            {
                throw f;
            }
        }
        _messageContext.getTransportOut().getSender().cleanup(_messageContext);
        return getallupdatedsoftwarereturn;
        Exception exception;
        exception;
        _messageContext.getTransportOut().getSender().cleanup(_messageContext);
        throw exception;
    }

    private Map getEnvelopeNamespaces(SOAPEnvelope env)
    {
        Map returnMap = new HashMap();
        OMNamespace ns;
        for(Iterator namespaceIterator = env.getAllDeclaredNamespaces(); namespaceIterator.hasNext(); returnMap.put(ns.getPrefix(), ns.getNamespaceURI()))
            ns = (OMNamespace)namespaceIterator.next();

        return returnMap;
    }

    private boolean optimizeContent(QName opName)
    {
        if(opNameArray == null)
            return false;
        for(int i = 0; i < opNameArray.length; i++)
            if(opName.equals(opNameArray[i]))
                return true;

        return false;
    }

    private OMElement toOM(GetUpdatedSoftwareWithinReleaseAndArch param, boolean optimizeContent)
        throws AxisFault
    {
        try
        {
            return param.getOMElement(GetUpdatedSoftwareWithinReleaseAndArch.MY_QNAME, OMAbstractFactory.getOMFactory());
        }
        catch(ADBException e)
        {
            throw AxisFault.makeFault(e);
        }
    }

    private OMElement toOM(GetUpdatedSoftwareWithinReleaseAndArchResponse param, boolean optimizeContent)
        throws AxisFault
    {
        try
        {
            return param.getOMElement(GetUpdatedSoftwareWithinReleaseAndArchResponse.MY_QNAME, OMAbstractFactory.getOMFactory());
        }
        catch(ADBException e)
        {
            throw AxisFault.makeFault(e);
        }
    }

    private OMElement toOM(GetUpdatedSoftwareWithinPasscodeAndArch param, boolean optimizeContent)
        throws AxisFault
    {
        try
        {
            return param.getOMElement(GetUpdatedSoftwareWithinPasscodeAndArch.MY_QNAME, OMAbstractFactory.getOMFactory());
        }
        catch(ADBException e)
        {
            throw AxisFault.makeFault(e);
        }
    }

    private OMElement toOM(GetUpdatedSoftwareWithinPasscodeAndArchResponse param, boolean optimizeContent)
        throws AxisFault
    {
        try
        {
            return param.getOMElement(GetUpdatedSoftwareWithinPasscodeAndArchResponse.MY_QNAME, OMAbstractFactory.getOMFactory());
        }
        catch(ADBException e)
        {
            throw AxisFault.makeFault(e);
        }
    }

    private OMElement toOM(GetSoftwareProductInfoByLicenseAndArchitectures param, boolean optimizeContent)
        throws AxisFault
    {
        try
        {
            return param.getOMElement(GetSoftwareProductInfoByLicenseAndArchitectures.MY_QNAME, OMAbstractFactory.getOMFactory());
        }
        catch(ADBException e)
        {
            throw AxisFault.makeFault(e);
        }
    }

    private OMElement toOM(GetSoftwareProductInfoByLicenseAndArchitecturesResponse param, boolean optimizeContent)
        throws AxisFault
    {
        try
        {
            return param.getOMElement(GetSoftwareProductInfoByLicenseAndArchitecturesResponse.MY_QNAME, OMAbstractFactory.getOMFactory());
        }
        catch(ADBException e)
        {
            throw AxisFault.makeFault(e);
        }
    }

    private OMElement toOM(Ping param, boolean optimizeContent)
        throws AxisFault
    {
        try
        {
            return param.getOMElement(Ping.MY_QNAME, OMAbstractFactory.getOMFactory());
        }
        catch(ADBException e)
        {
            throw AxisFault.makeFault(e);
        }
    }

    private OMElement toOM(PingResponse param, boolean optimizeContent)
        throws AxisFault
    {
        try
        {
            return param.getOMElement(PingResponse.MY_QNAME, OMAbstractFactory.getOMFactory());
        }
        catch(ADBException e)
        {
            throw AxisFault.makeFault(e);
        }
    }

    private OMElement toOM(GetUpdatedSoftwareWithinRelease param, boolean optimizeContent)
        throws AxisFault
    {
        try
        {
            return param.getOMElement(GetUpdatedSoftwareWithinRelease.MY_QNAME, OMAbstractFactory.getOMFactory());
        }
        catch(ADBException e)
        {
            throw AxisFault.makeFault(e);
        }
    }

    private OMElement toOM(GetUpdatedSoftwareWithinReleaseResponse param, boolean optimizeContent)
        throws AxisFault
    {
        try
        {
            return param.getOMElement(GetUpdatedSoftwareWithinReleaseResponse.MY_QNAME, OMAbstractFactory.getOMFactory());
        }
        catch(ADBException e)
        {
            throw AxisFault.makeFault(e);
        }
    }

    private OMElement toOM(GetAllUpdatedSoftware param, boolean optimizeContent)
        throws AxisFault
    {
        try
        {
            return param.getOMElement(GetAllUpdatedSoftware.MY_QNAME, OMAbstractFactory.getOMFactory());
        }
        catch(ADBException e)
        {
            throw AxisFault.makeFault(e);
        }
    }

    private OMElement toOM(GetAllUpdatedSoftwareResponse param, boolean optimizeContent)
        throws AxisFault
    {
        try
        {
            return param.getOMElement(GetAllUpdatedSoftwareResponse.MY_QNAME, OMAbstractFactory.getOMFactory());
        }
        catch(ADBException e)
        {
            throw AxisFault.makeFault(e);
        }
    }

    private SOAPEnvelope toEnvelope(SOAPFactory factory, String param1, BitVer param2[], String param3, String param4, String param5, GetUpdatedSoftwareWithinReleaseAndArch dummyWrappedType, 
            boolean optimizeContent)
        throws AxisFault
    {
        try
        {
            GetUpdatedSoftwareWithinReleaseAndArch wrappedType = new GetUpdatedSoftwareWithinReleaseAndArch();
            wrappedType.setRelease(param1);
            wrappedType.setProducts(param2);
            wrappedType.setArchitecture(param3);
            wrappedType.setClientString(param4);
            wrappedType.setLocale(param5);
            SOAPEnvelope emptyEnvelope = factory.getDefaultEnvelope();
            emptyEnvelope.getBody().addChild(wrappedType.getOMElement(GetUpdatedSoftwareWithinReleaseAndArch.MY_QNAME, factory));
            return emptyEnvelope;
        }
        catch(ADBException e)
        {
            throw AxisFault.makeFault(e);
        }
    }

    private GetUpdatedSoftwareWithinReleaseAndArchReturn getGetUpdatedSoftwareWithinReleaseAndArchResponseResponse(GetUpdatedSoftwareWithinReleaseAndArchResponse wrappedType)
    {
        return wrappedType.getResponse();
    }

    private SOAPEnvelope toEnvelope(SOAPFactory factory, BitVer param1[], String param2, String param3, String param4, GetUpdatedSoftwareWithinPasscodeAndArch dummyWrappedType, boolean optimizeContent)
        throws AxisFault
    {
        try
        {
            GetUpdatedSoftwareWithinPasscodeAndArch wrappedType = new GetUpdatedSoftwareWithinPasscodeAndArch();
            wrappedType.setBv(param1);
            wrappedType.setArchitecture(param2);
            wrappedType.setClientString(param3);
            wrappedType.setLocale(param4);
            SOAPEnvelope emptyEnvelope = factory.getDefaultEnvelope();
            emptyEnvelope.getBody().addChild(wrappedType.getOMElement(GetUpdatedSoftwareWithinPasscodeAndArch.MY_QNAME, factory));
            return emptyEnvelope;
        }
        catch(ADBException e)
        {
            throw AxisFault.makeFault(e);
        }
    }

    private GetUpdatedSoftwareWithinPasscodeAndArchReturn getGetUpdatedSoftwareWithinPasscodeAndArchResponseResponse(GetUpdatedSoftwareWithinPasscodeAndArchResponse wrappedType)
    {
        return wrappedType.getResponse();
    }

    private SOAPEnvelope toEnvelope(SOAPFactory factory, String param1, String param2, String param3, String param4[], String param5, String param6, 
            GetSoftwareProductInfoByLicenseAndArchitectures dummyWrappedType, boolean optimizeContent)
        throws AxisFault
    {
        try
        {
            GetSoftwareProductInfoByLicenseAndArchitectures wrappedType = new GetSoftwareProductInfoByLicenseAndArchitectures();
            wrappedType.setSecurityToken(param1);
            wrappedType.setRelease(param2);
            wrappedType.setLicenseId(param3);
            wrappedType.setRequestedArchitectures(param4);
            wrappedType.setClientString(param5);
            wrappedType.setLocale(param6);
            SOAPEnvelope emptyEnvelope = factory.getDefaultEnvelope();
            emptyEnvelope.getBody().addChild(wrappedType.getOMElement(GetSoftwareProductInfoByLicenseAndArchitectures.MY_QNAME, factory));
            return emptyEnvelope;
        }
        catch(ADBException e)
        {
            throw AxisFault.makeFault(e);
        }
    }

    private GetSoftwareProductInfoByLicenseAndArchitecturesReturn getGetSoftwareProductInfoByLicenseAndArchitecturesResponseResponse(GetSoftwareProductInfoByLicenseAndArchitecturesResponse wrappedType)
    {
        return wrappedType.getResponse();
    }

    private SOAPEnvelope toEnvelope(SOAPFactory factory, String param1, Ping dummyWrappedType, boolean optimizeContent)
        throws AxisFault
    {
        try
        {
            Ping wrappedType = new Ping();
            wrappedType.setRequest(param1);
            SOAPEnvelope emptyEnvelope = factory.getDefaultEnvelope();
            emptyEnvelope.getBody().addChild(wrappedType.getOMElement(Ping.MY_QNAME, factory));
            return emptyEnvelope;
        }
        catch(ADBException e)
        {
            throw AxisFault.makeFault(e);
        }
    }

    private String getPingResponsePingReturn(PingResponse wrappedType)
    {
        return wrappedType.getPingReturn();
    }

    private SOAPEnvelope toEnvelope(SOAPFactory factory, BitVer param1[], String param2, String param3, GetUpdatedSoftwareWithinRelease dummyWrappedType, boolean optimizeContent)
        throws AxisFault
    {
        try
        {
            GetUpdatedSoftwareWithinRelease wrappedType = new GetUpdatedSoftwareWithinRelease();
            wrappedType.setBv(param1);
            wrappedType.setClientString(param2);
            wrappedType.setLocale(param3);
            SOAPEnvelope emptyEnvelope = factory.getDefaultEnvelope();
            emptyEnvelope.getBody().addChild(wrappedType.getOMElement(GetUpdatedSoftwareWithinRelease.MY_QNAME, factory));
            return emptyEnvelope;
        }
        catch(ADBException e)
        {
            throw AxisFault.makeFault(e);
        }
    }

    private GetUpdatedSoftwareWithinReleaseReturn getGetUpdatedSoftwareWithinReleaseResponseResponse(GetUpdatedSoftwareWithinReleaseResponse wrappedType)
    {
        return wrappedType.getResponse();
    }

    private SOAPEnvelope toEnvelope(SOAPFactory factory, String param1, String param2, GetAllUpdatedSoftware dummyWrappedType, boolean optimizeContent)
        throws AxisFault
    {
        try
        {
            GetAllUpdatedSoftware wrappedType = new GetAllUpdatedSoftware();
            wrappedType.setClientString(param1);
            wrappedType.setLocale(param2);
            SOAPEnvelope emptyEnvelope = factory.getDefaultEnvelope();
            emptyEnvelope.getBody().addChild(wrappedType.getOMElement(GetAllUpdatedSoftware.MY_QNAME, factory));
            return emptyEnvelope;
        }
        catch(ADBException e)
        {
            throw AxisFault.makeFault(e);
        }
    }

    private GetAllUpdatedSoftwareReturn getGetAllUpdatedSoftwareResponseResponse(GetAllUpdatedSoftwareResponse wrappedType)
    {
        return wrappedType.getResponse();
    }

    private SOAPEnvelope toEnvelope(SOAPFactory factory)
    {
        return factory.getDefaultEnvelope();
    }

    private Object fromOM(OMElement param, Class type, Map extraNamespaces)
        throws AxisFault
    {
        try
        {
            if(com/mathworks/internal/dws/client/v3/GetUpdatedSoftwareWithinReleaseAndArch.equals(type))
                return GetUpdatedSoftwareWithinReleaseAndArch.Factory.parse(param.getXMLStreamReaderWithoutCaching());
        }
        catch(Exception e)
        {
            throw AxisFault.makeFault(e);
        }
        if(com/mathworks/internal/dws/client/v3/GetUpdatedSoftwareWithinReleaseAndArchResponse.equals(type))
            return GetUpdatedSoftwareWithinReleaseAndArchResponse.Factory.parse(param.getXMLStreamReaderWithoutCaching());
        if(com/mathworks/internal/dws/client/v3/GetUpdatedSoftwareWithinPasscodeAndArch.equals(type))
            return GetUpdatedSoftwareWithinPasscodeAndArch.Factory.parse(param.getXMLStreamReaderWithoutCaching());
        if(com/mathworks/internal/dws/client/v3/GetUpdatedSoftwareWithinPasscodeAndArchResponse.equals(type))
            return GetUpdatedSoftwareWithinPasscodeAndArchResponse.Factory.parse(param.getXMLStreamReaderWithoutCaching());
        if(com/mathworks/internal/dws/client/v3/GetSoftwareProductInfoByLicenseAndArchitectures.equals(type))
            return GetSoftwareProductInfoByLicenseAndArchitectures.Factory.parse(param.getXMLStreamReaderWithoutCaching());
        if(com/mathworks/internal/dws/client/v3/GetSoftwareProductInfoByLicenseAndArchitecturesResponse.equals(type))
            return GetSoftwareProductInfoByLicenseAndArchitecturesResponse.Factory.parse(param.getXMLStreamReaderWithoutCaching());
        if(com/mathworks/internal/dws/client/v3/Ping.equals(type))
            return Ping.Factory.parse(param.getXMLStreamReaderWithoutCaching());
        if(com/mathworks/internal/dws/client/v3/PingResponse.equals(type))
            return PingResponse.Factory.parse(param.getXMLStreamReaderWithoutCaching());
        if(com/mathworks/internal/dws/client/v3/GetUpdatedSoftwareWithinRelease.equals(type))
            return GetUpdatedSoftwareWithinRelease.Factory.parse(param.getXMLStreamReaderWithoutCaching());
        if(com/mathworks/internal/dws/client/v3/GetUpdatedSoftwareWithinReleaseResponse.equals(type))
            return GetUpdatedSoftwareWithinReleaseResponse.Factory.parse(param.getXMLStreamReaderWithoutCaching());
        if(com/mathworks/internal/dws/client/v3/GetAllUpdatedSoftware.equals(type))
            return GetAllUpdatedSoftware.Factory.parse(param.getXMLStreamReaderWithoutCaching());
        if(com/mathworks/internal/dws/client/v3/GetAllUpdatedSoftwareResponse.equals(type))
            return GetAllUpdatedSoftwareResponse.Factory.parse(param.getXMLStreamReaderWithoutCaching());
        return null;
    }

    protected AxisOperation _operations[];
    private HashMap faultExceptionNameMap;
    private HashMap faultExceptionClassNameMap;
    private HashMap faultMessageMap;
    private static int counter = 0;
    private QName opNameArray[];

}
