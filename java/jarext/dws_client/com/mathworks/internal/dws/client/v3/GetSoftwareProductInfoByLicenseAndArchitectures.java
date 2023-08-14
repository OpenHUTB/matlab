// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   GetSoftwareProductInfoByLicenseAndArchitectures.java

package com.mathworks.internal.dws.client.v3;

import java.util.*;
import javax.xml.namespace.NamespaceContext;
import javax.xml.namespace.QName;
import javax.xml.stream.*;
import org.apache.axiom.om.OMElement;
import org.apache.axiom.om.OMFactory;
import org.apache.axiom.om.impl.llom.OMSourcedElementImpl;
import org.apache.axis2.databinding.*;
import org.apache.axis2.databinding.utils.BeanUtil;
import org.apache.axis2.databinding.utils.ConverterUtil;
import org.apache.axis2.databinding.utils.reader.ADBXMLStreamReaderImpl;
import org.apache.axis2.databinding.utils.writer.MTOMAwareXMLStreamWriter;

// Referenced classes of package com.mathworks.internal.dws.client.v3:
//            ExtensionMapper

public class GetSoftwareProductInfoByLicenseAndArchitectures
    implements ADBBean
{
    public static class Factory
    {

        public static GetSoftwareProductInfoByLicenseAndArchitectures parse(XMLStreamReader reader)
            throws Exception
        {
            GetSoftwareProductInfoByLicenseAndArchitectures object;
            object = new GetSoftwareProductInfoByLicenseAndArchitectures();
            String nillableValue = null;
            String prefix = "";
            String namespaceuri = "";
            Vector handledAttributes;
            ArrayList list4;
            String content;
            boolean loopDone4;
            try
            {
                for(; !reader.isStartElement() && !reader.isEndElement(); reader.next());
                if(reader.getAttributeValue("http://www.w3.org/2001/XMLSchema-instance", "type") != null)
                {
                    String fullTypeName = reader.getAttributeValue("http://www.w3.org/2001/XMLSchema-instance", "type");
                    if(fullTypeName != null)
                    {
                        String nsPrefix = null;
                        if(fullTypeName.indexOf(":") > -1)
                            nsPrefix = fullTypeName.substring(0, fullTypeName.indexOf(":"));
                        nsPrefix = nsPrefix != null ? nsPrefix : "";
                        String type = fullTypeName.substring(fullTypeName.indexOf(":") + 1);
                        if(!"getSoftwareProductInfoByLicenseAndArchitectures".equals(type))
                        {
                            String nsUri = reader.getNamespaceContext().getNamespaceURI(nsPrefix);
                            return (GetSoftwareProductInfoByLicenseAndArchitectures)ExtensionMapper.getTypeObject(nsUri, type, reader);
                        }
                    }
                }
            }
            catch(XMLStreamException e)
            {
                throw new Exception(e);
            }
            handledAttributes = new Vector();
            reader.next();
            list4 = new ArrayList();
            for(; !reader.isStartElement() && !reader.isEndElement(); reader.next());
            if(reader.isStartElement() && (new QName("https://services.mathworks.com/dws3/services/DownloadService", "securityToken")).equals(reader.getName()))
            {
                content = reader.getElementText();
                object.setSecurityToken(ConverterUtil.convertToString(content));
                reader.next();
            } else
            {
                throw new ADBException((new StringBuilder()).append("Unexpected subelement ").append(reader.getLocalName()).toString());
            }
            for(; !reader.isStartElement() && !reader.isEndElement(); reader.next());
            if(reader.isStartElement() && (new QName("https://services.mathworks.com/dws3/services/DownloadService", "release")).equals(reader.getName()))
            {
                content = reader.getElementText();
                object.setRelease(ConverterUtil.convertToString(content));
                reader.next();
            } else
            {
                throw new ADBException((new StringBuilder()).append("Unexpected subelement ").append(reader.getLocalName()).toString());
            }
            for(; !reader.isStartElement() && !reader.isEndElement(); reader.next());
            if(reader.isStartElement() && (new QName("https://services.mathworks.com/dws3/services/DownloadService", "licenseId")).equals(reader.getName()))
            {
                content = reader.getElementText();
                object.setLicenseId(ConverterUtil.convertToString(content));
                reader.next();
            } else
            {
                throw new ADBException((new StringBuilder()).append("Unexpected subelement ").append(reader.getLocalName()).toString());
            }
            for(; !reader.isStartElement() && !reader.isEndElement(); reader.next());
            if(reader.isStartElement() && (new QName("https://services.mathworks.com/dws3/services/DownloadService", "requestedArchitectures")).equals(reader.getName()))
            {
                list4.add(reader.getElementText());
                loopDone4 = false;
                while(!loopDone4) 
                {
                    for(; !reader.isEndElement(); reader.next());
                    reader.next();
                    for(; !reader.isStartElement() && !reader.isEndElement(); reader.next());
                    if(reader.isEndElement())
                        loopDone4 = true;
                    else
                    if((new QName("https://services.mathworks.com/dws3/services/DownloadService", "requestedArchitectures")).equals(reader.getName()))
                        list4.add(reader.getElementText());
                    else
                        loopDone4 = true;
                }
                object.setRequestedArchitectures((String[])(String[])list4.toArray(new String[list4.size()]));
            } else
            {
                throw new ADBException((new StringBuilder()).append("Unexpected subelement ").append(reader.getLocalName()).toString());
            }
            for(; !reader.isStartElement() && !reader.isEndElement(); reader.next());
            if(reader.isStartElement() && (new QName("https://services.mathworks.com/dws3/services/DownloadService", "clientString")).equals(reader.getName()))
            {
                loopDone4 = reader.getElementText();
                object.setClientString(ConverterUtil.convertToString(loopDone4));
                reader.next();
            } else
            {
                throw new ADBException((new StringBuilder()).append("Unexpected subelement ").append(reader.getLocalName()).toString());
            }
            for(; !reader.isStartElement() && !reader.isEndElement(); reader.next());
            if(reader.isStartElement() && (new QName("https://services.mathworks.com/dws3/services/DownloadService", "locale")).equals(reader.getName()))
            {
                loopDone4 = reader.getElementText();
                object.setLocale(ConverterUtil.convertToString(loopDone4));
                reader.next();
            } else
            {
                throw new ADBException((new StringBuilder()).append("Unexpected subelement ").append(reader.getLocalName()).toString());
            }
            for(; !reader.isStartElement() && !reader.isEndElement(); reader.next());
            if(reader.isStartElement())
                throw new ADBException((new StringBuilder()).append("Unexpected subelement ").append(reader.getLocalName()).toString());
            return object;
        }

        public Factory()
        {
        }
    }


    public GetSoftwareProductInfoByLicenseAndArchitectures()
    {
    }

    private static String generatePrefix(String namespace)
    {
        if(namespace.equals("https://services.mathworks.com/dws3/services/DownloadService"))
            return "ns1";
        else
            return BeanUtil.getUniquePrefix();
    }

    public String getSecurityToken()
    {
        return localSecurityToken;
    }

    public void setSecurityToken(String param)
    {
        localSecurityToken = param;
    }

    public String getRelease()
    {
        return localRelease;
    }

    public void setRelease(String param)
    {
        localRelease = param;
    }

    public String getLicenseId()
    {
        return localLicenseId;
    }

    public void setLicenseId(String param)
    {
        localLicenseId = param;
    }

    public String[] getRequestedArchitectures()
    {
        return localRequestedArchitectures;
    }

    protected void validateRequestedArchitectures(String param[])
    {
        if(param != null && param.length < 1)
            throw new RuntimeException();
        else
            return;
    }

    public void setRequestedArchitectures(String param[])
    {
        validateRequestedArchitectures(param);
        localRequestedArchitectures = param;
    }

    public void addRequestedArchitectures(String param)
    {
        if(localRequestedArchitectures == null)
            localRequestedArchitectures = new String[0];
        List list = ConverterUtil.toList(localRequestedArchitectures);
        list.add(param);
        localRequestedArchitectures = (String[])(String[])list.toArray(new String[list.size()]);
    }

    public String getClientString()
    {
        return localClientString;
    }

    public void setClientString(String param)
    {
        localClientString = param;
    }

    public String getLocale()
    {
        return localLocale;
    }

    public void setLocale(String param)
    {
        localLocale = param;
    }

    public static boolean isReaderMTOMAware(XMLStreamReader reader)
    {
        boolean isReaderMTOMAware = false;
        try
        {
            isReaderMTOMAware = Boolean.TRUE.equals(reader.getProperty("IsDatahandlersAwareParsing"));
        }
        catch(IllegalArgumentException e)
        {
            isReaderMTOMAware = false;
        }
        return isReaderMTOMAware;
    }

    public OMElement getOMElement(QName parentQName, OMFactory factory)
        throws ADBException
    {
        org.apache.axiom.om.OMDataSource dataSource = new ADBDataSource(MY_QNAME, factory) {

            public void serialize(MTOMAwareXMLStreamWriter xmlWriter)
                throws XMLStreamException
            {
                GetSoftwareProductInfoByLicenseAndArchitectures.this.serialize(GetSoftwareProductInfoByLicenseAndArchitectures.MY_QNAME, factory, xmlWriter);
            }

            final OMFactory val$factory;
            final GetSoftwareProductInfoByLicenseAndArchitectures this$0;

            
            {
                this$0 = GetSoftwareProductInfoByLicenseAndArchitectures.this;
                factory = omfactory;
                super(x0, x1);
            }
        }
;
        return new OMSourcedElementImpl(MY_QNAME, factory, dataSource);
    }

    public void serialize(QName parentQName, OMFactory factory, MTOMAwareXMLStreamWriter xmlWriter)
        throws XMLStreamException, ADBException
    {
        serialize(parentQName, factory, xmlWriter, false);
    }

    public void serialize(QName parentQName, OMFactory factory, MTOMAwareXMLStreamWriter xmlWriter, boolean serializeType)
        throws XMLStreamException, ADBException
    {
        String prefix = null;
        String namespace = null;
        prefix = parentQName.getPrefix();
        namespace = parentQName.getNamespaceURI();
        if(namespace != null && namespace.trim().length() > 0)
        {
            String writerPrefix = xmlWriter.getPrefix(namespace);
            if(writerPrefix != null)
            {
                xmlWriter.writeStartElement(namespace, parentQName.getLocalPart());
            } else
            {
                if(prefix == null)
                    prefix = generatePrefix(namespace);
                xmlWriter.writeStartElement(prefix, parentQName.getLocalPart(), namespace);
                xmlWriter.writeNamespace(prefix, namespace);
                xmlWriter.setPrefix(prefix, namespace);
            }
        } else
        {
            xmlWriter.writeStartElement(parentQName.getLocalPart());
        }
        if(serializeType)
        {
            String namespacePrefix = registerPrefix(xmlWriter, "https://services.mathworks.com/dws3/services/DownloadService");
            if(namespacePrefix != null && namespacePrefix.trim().length() > 0)
                writeAttribute("xsi", "http://www.w3.org/2001/XMLSchema-instance", "type", (new StringBuilder()).append(namespacePrefix).append(":getSoftwareProductInfoByLicenseAndArchitectures").toString(), xmlWriter);
            else
                writeAttribute("xsi", "http://www.w3.org/2001/XMLSchema-instance", "type", "getSoftwareProductInfoByLicenseAndArchitectures", xmlWriter);
        }
        namespace = "https://services.mathworks.com/dws3/services/DownloadService";
        if(!namespace.equals(""))
        {
            prefix = xmlWriter.getPrefix(namespace);
            if(prefix == null)
            {
                prefix = generatePrefix(namespace);
                xmlWriter.writeStartElement(prefix, "securityToken", namespace);
                xmlWriter.writeNamespace(prefix, namespace);
                xmlWriter.setPrefix(prefix, namespace);
            } else
            {
                xmlWriter.writeStartElement(namespace, "securityToken");
            }
        } else
        {
            xmlWriter.writeStartElement("securityToken");
        }
        if(localSecurityToken == null)
            throw new ADBException("securityToken cannot be null!!");
        xmlWriter.writeCharacters(localSecurityToken);
        xmlWriter.writeEndElement();
        namespace = "https://services.mathworks.com/dws3/services/DownloadService";
        if(!namespace.equals(""))
        {
            prefix = xmlWriter.getPrefix(namespace);
            if(prefix == null)
            {
                prefix = generatePrefix(namespace);
                xmlWriter.writeStartElement(prefix, "release", namespace);
                xmlWriter.writeNamespace(prefix, namespace);
                xmlWriter.setPrefix(prefix, namespace);
            } else
            {
                xmlWriter.writeStartElement(namespace, "release");
            }
        } else
        {
            xmlWriter.writeStartElement("release");
        }
        if(localRelease == null)
            throw new ADBException("release cannot be null!!");
        xmlWriter.writeCharacters(localRelease);
        xmlWriter.writeEndElement();
        namespace = "https://services.mathworks.com/dws3/services/DownloadService";
        if(!namespace.equals(""))
        {
            prefix = xmlWriter.getPrefix(namespace);
            if(prefix == null)
            {
                prefix = generatePrefix(namespace);
                xmlWriter.writeStartElement(prefix, "licenseId", namespace);
                xmlWriter.writeNamespace(prefix, namespace);
                xmlWriter.setPrefix(prefix, namespace);
            } else
            {
                xmlWriter.writeStartElement(namespace, "licenseId");
            }
        } else
        {
            xmlWriter.writeStartElement("licenseId");
        }
        if(localLicenseId == null)
            throw new ADBException("licenseId cannot be null!!");
        xmlWriter.writeCharacters(localLicenseId);
        xmlWriter.writeEndElement();
        if(localRequestedArchitectures != null)
        {
            namespace = "https://services.mathworks.com/dws3/services/DownloadService";
            boolean emptyNamespace = namespace == null || namespace.length() == 0;
            prefix = emptyNamespace ? null : xmlWriter.getPrefix(namespace);
            for(int i = 0; i < localRequestedArchitectures.length; i++)
                if(localRequestedArchitectures[i] != null)
                {
                    if(!emptyNamespace)
                    {
                        if(prefix == null)
                        {
                            String prefix2 = generatePrefix(namespace);
                            xmlWriter.writeStartElement(prefix2, "requestedArchitectures", namespace);
                            xmlWriter.writeNamespace(prefix2, namespace);
                            xmlWriter.setPrefix(prefix2, namespace);
                        } else
                        {
                            xmlWriter.writeStartElement(namespace, "requestedArchitectures");
                        }
                    } else
                    {
                        xmlWriter.writeStartElement("requestedArchitectures");
                    }
                    xmlWriter.writeCharacters(ConverterUtil.convertToString(localRequestedArchitectures[i]));
                    xmlWriter.writeEndElement();
                } else
                {
                    throw new ADBException("requestedArchitectures cannot be null!!");
                }

        } else
        {
            throw new ADBException("requestedArchitectures cannot be null!!");
        }
        namespace = "https://services.mathworks.com/dws3/services/DownloadService";
        if(!namespace.equals(""))
        {
            prefix = xmlWriter.getPrefix(namespace);
            if(prefix == null)
            {
                prefix = generatePrefix(namespace);
                xmlWriter.writeStartElement(prefix, "clientString", namespace);
                xmlWriter.writeNamespace(prefix, namespace);
                xmlWriter.setPrefix(prefix, namespace);
            } else
            {
                xmlWriter.writeStartElement(namespace, "clientString");
            }
        } else
        {
            xmlWriter.writeStartElement("clientString");
        }
        if(localClientString == null)
            throw new ADBException("clientString cannot be null!!");
        xmlWriter.writeCharacters(localClientString);
        xmlWriter.writeEndElement();
        namespace = "https://services.mathworks.com/dws3/services/DownloadService";
        if(!namespace.equals(""))
        {
            prefix = xmlWriter.getPrefix(namespace);
            if(prefix == null)
            {
                prefix = generatePrefix(namespace);
                xmlWriter.writeStartElement(prefix, "locale", namespace);
                xmlWriter.writeNamespace(prefix, namespace);
                xmlWriter.setPrefix(prefix, namespace);
            } else
            {
                xmlWriter.writeStartElement(namespace, "locale");
            }
        } else
        {
            xmlWriter.writeStartElement("locale");
        }
        if(localLocale == null)
        {
            throw new ADBException("locale cannot be null!!");
        } else
        {
            xmlWriter.writeCharacters(localLocale);
            xmlWriter.writeEndElement();
            xmlWriter.writeEndElement();
            return;
        }
    }

    private void writeAttribute(String prefix, String namespace, String attName, String attValue, XMLStreamWriter xmlWriter)
        throws XMLStreamException
    {
        if(xmlWriter.getPrefix(namespace) == null)
        {
            xmlWriter.writeNamespace(prefix, namespace);
            xmlWriter.setPrefix(prefix, namespace);
        }
        xmlWriter.writeAttribute(namespace, attName, attValue);
    }

    private void writeAttribute(String namespace, String attName, String attValue, XMLStreamWriter xmlWriter)
        throws XMLStreamException
    {
        if(namespace.equals(""))
        {
            xmlWriter.writeAttribute(attName, attValue);
        } else
        {
            registerPrefix(xmlWriter, namespace);
            xmlWriter.writeAttribute(namespace, attName, attValue);
        }
    }

    private void writeQNameAttribute(String namespace, String attName, QName qname, XMLStreamWriter xmlWriter)
        throws XMLStreamException
    {
        String attributeNamespace = qname.getNamespaceURI();
        String attributePrefix = xmlWriter.getPrefix(attributeNamespace);
        if(attributePrefix == null)
            attributePrefix = registerPrefix(xmlWriter, attributeNamespace);
        String attributeValue;
        if(attributePrefix.trim().length() > 0)
            attributeValue = (new StringBuilder()).append(attributePrefix).append(":").append(qname.getLocalPart()).toString();
        else
            attributeValue = qname.getLocalPart();
        if(namespace.equals(""))
        {
            xmlWriter.writeAttribute(attName, attributeValue);
        } else
        {
            registerPrefix(xmlWriter, namespace);
            xmlWriter.writeAttribute(namespace, attName, attributeValue);
        }
    }

    private void writeQName(QName qname, XMLStreamWriter xmlWriter)
        throws XMLStreamException
    {
        String namespaceURI = qname.getNamespaceURI();
        if(namespaceURI != null)
        {
            String prefix = xmlWriter.getPrefix(namespaceURI);
            if(prefix == null)
            {
                prefix = generatePrefix(namespaceURI);
                xmlWriter.writeNamespace(prefix, namespaceURI);
                xmlWriter.setPrefix(prefix, namespaceURI);
            }
            if(prefix.trim().length() > 0)
                xmlWriter.writeCharacters((new StringBuilder()).append(prefix).append(":").append(ConverterUtil.convertToString(qname)).toString());
            else
                xmlWriter.writeCharacters(ConverterUtil.convertToString(qname));
        } else
        {
            xmlWriter.writeCharacters(ConverterUtil.convertToString(qname));
        }
    }

    private void writeQNames(QName qnames[], XMLStreamWriter xmlWriter)
        throws XMLStreamException
    {
        if(qnames != null)
        {
            StringBuffer stringToWrite = new StringBuffer();
            String namespaceURI = null;
            String prefix = null;
            for(int i = 0; i < qnames.length; i++)
            {
                if(i > 0)
                    stringToWrite.append(" ");
                namespaceURI = qnames[i].getNamespaceURI();
                if(namespaceURI != null)
                {
                    prefix = xmlWriter.getPrefix(namespaceURI);
                    if(prefix == null || prefix.length() == 0)
                    {
                        prefix = generatePrefix(namespaceURI);
                        xmlWriter.writeNamespace(prefix, namespaceURI);
                        xmlWriter.setPrefix(prefix, namespaceURI);
                    }
                    if(prefix.trim().length() > 0)
                        stringToWrite.append(prefix).append(":").append(ConverterUtil.convertToString(qnames[i]));
                    else
                        stringToWrite.append(ConverterUtil.convertToString(qnames[i]));
                } else
                {
                    stringToWrite.append(ConverterUtil.convertToString(qnames[i]));
                }
            }

            xmlWriter.writeCharacters(stringToWrite.toString());
        }
    }

    private String registerPrefix(XMLStreamWriter xmlWriter, String namespace)
        throws XMLStreamException
    {
        String prefix = xmlWriter.getPrefix(namespace);
        if(prefix == null)
        {
            for(prefix = generatePrefix(namespace); xmlWriter.getNamespaceContext().getNamespaceURI(prefix) != null; prefix = BeanUtil.getUniquePrefix());
            xmlWriter.writeNamespace(prefix, namespace);
            xmlWriter.setPrefix(prefix, namespace);
        }
        return prefix;
    }

    public XMLStreamReader getPullParser(QName qName)
        throws ADBException
    {
        ArrayList elementList = new ArrayList();
        ArrayList attribList = new ArrayList();
        elementList.add(new QName("https://services.mathworks.com/dws3/services/DownloadService", "securityToken"));
        if(localSecurityToken != null)
            elementList.add(ConverterUtil.convertToString(localSecurityToken));
        else
            throw new ADBException("securityToken cannot be null!!");
        elementList.add(new QName("https://services.mathworks.com/dws3/services/DownloadService", "release"));
        if(localRelease != null)
            elementList.add(ConverterUtil.convertToString(localRelease));
        else
            throw new ADBException("release cannot be null!!");
        elementList.add(new QName("https://services.mathworks.com/dws3/services/DownloadService", "licenseId"));
        if(localLicenseId != null)
            elementList.add(ConverterUtil.convertToString(localLicenseId));
        else
            throw new ADBException("licenseId cannot be null!!");
        if(localRequestedArchitectures != null)
        {
            for(int i = 0; i < localRequestedArchitectures.length; i++)
                if(localRequestedArchitectures[i] != null)
                {
                    elementList.add(new QName("https://services.mathworks.com/dws3/services/DownloadService", "requestedArchitectures"));
                    elementList.add(ConverterUtil.convertToString(localRequestedArchitectures[i]));
                } else
                {
                    throw new ADBException("requestedArchitectures cannot be null!!");
                }

        } else
        {
            throw new ADBException("requestedArchitectures cannot be null!!");
        }
        elementList.add(new QName("https://services.mathworks.com/dws3/services/DownloadService", "clientString"));
        if(localClientString != null)
            elementList.add(ConverterUtil.convertToString(localClientString));
        else
            throw new ADBException("clientString cannot be null!!");
        elementList.add(new QName("https://services.mathworks.com/dws3/services/DownloadService", "locale"));
        if(localLocale != null)
            elementList.add(ConverterUtil.convertToString(localLocale));
        else
            throw new ADBException("locale cannot be null!!");
        return new ADBXMLStreamReaderImpl(qName, elementList.toArray(), attribList.toArray());
    }

    public static final QName MY_QNAME = new QName("https://services.mathworks.com/dws3/services/DownloadService", "getSoftwareProductInfoByLicenseAndArchitectures", "ns1");
    protected String localSecurityToken;
    protected String localRelease;
    protected String localLicenseId;
    protected String localRequestedArchitectures[];
    protected String localClientString;
    protected String localLocale;

}
