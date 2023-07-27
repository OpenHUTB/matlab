// Decompiled by Jad v1.5.8g. Copyright 2001 Pavel Kouznetsov.
// Jad home page: http://www.kpdus.com/jad.html
// Decompiler options: packimports(3) 
// Source File Name:   Server.java

package com.mathworks.internal.dws.client.v3;

import java.util.ArrayList;
import java.util.Vector;
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

public class Server
    implements ADBBean
{
    public static class Factory
    {

        public static Server parse(XMLStreamReader reader)
            throws Exception
        {
            Server object;
            object = new Server();
            String nillableValue = null;
            String prefix = "";
            String namespaceuri = "";
            Vector handledAttributes;
            String content;
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
                        if(!"Server".equals(type))
                        {
                            String nsUri = reader.getNamespaceContext().getNamespaceURI(nsPrefix);
                            return (Server)ExtensionMapper.getTypeObject(nsUri, type, reader);
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
            for(; !reader.isStartElement() && !reader.isEndElement(); reader.next());
            if(reader.isStartElement() && (new QName("https://services.mathworks.com/dws3/services/DownloadService", "server")).equals(reader.getName()))
            {
                nillableValue = reader.getAttributeValue("http://www.w3.org/2001/XMLSchema-instance", "nil");
                if(!"true".equals(nillableValue) && !"1".equals(nillableValue))
                {
                    content = reader.getElementText();
                    object.setServer(ConverterUtil.convertToString(content));
                } else
                {
                    reader.getElementText();
                }
                reader.next();
            } else
            {
                throw new ADBException((new StringBuilder()).append("Unexpected subelement ").append(reader.getLocalName()).toString());
            }
            for(; !reader.isStartElement() && !reader.isEndElement(); reader.next());
            if(reader.isStartElement() && (new QName("https://services.mathworks.com/dws3/services/DownloadService", "transport")).equals(reader.getName()))
            {
                nillableValue = reader.getAttributeValue("http://www.w3.org/2001/XMLSchema-instance", "nil");
                if(!"true".equals(nillableValue) && !"1".equals(nillableValue))
                {
                    content = reader.getElementText();
                    object.setTransport(ConverterUtil.convertToString(content));
                } else
                {
                    reader.getElementText();
                }
                reader.next();
            } else
            {
                throw new ADBException((new StringBuilder()).append("Unexpected subelement ").append(reader.getLocalName()).toString());
            }
            for(; !reader.isStartElement() && !reader.isEndElement(); reader.next());
            if(reader.isStartElement() && (new QName("https://services.mathworks.com/dws3/services/DownloadService", "uniqueId")).equals(reader.getName()))
            {
                nillableValue = reader.getAttributeValue("http://www.w3.org/2001/XMLSchema-instance", "nil");
                if(!"true".equals(nillableValue) && !"1".equals(nillableValue))
                {
                    content = reader.getElementText();
                    object.setUniqueId(ConverterUtil.convertToString(content));
                } else
                {
                    reader.getElementText();
                }
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


    public Server()
    {
    }

    private static String generatePrefix(String namespace)
    {
        if(namespace.equals("https://services.mathworks.com/dws3/services/DownloadService"))
            return "ns1";
        else
            return BeanUtil.getUniquePrefix();
    }

    public String getServer()
    {
        return localServer;
    }

    public void setServer(String param)
    {
        localServer = param;
    }

    public String getTransport()
    {
        return localTransport;
    }

    public void setTransport(String param)
    {
        localTransport = param;
    }

    public String getUniqueId()
    {
        return localUniqueId;
    }

    public void setUniqueId(String param)
    {
        localUniqueId = param;
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
        org.apache.axiom.om.OMDataSource dataSource = new ADBDataSource(parentQName, factory) {

            public void serialize(MTOMAwareXMLStreamWriter xmlWriter)
                throws XMLStreamException
            {
                Server.this.serialize(parentQName, factory, xmlWriter);
            }

            final OMFactory val$factory;
            final Server this$0;

            
            {
                this$0 = Server.this;
                factory = omfactory;
                super(x0, x1);
            }
        }
;
        return new OMSourcedElementImpl(parentQName, factory, dataSource);
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
                writeAttribute("xsi", "http://www.w3.org/2001/XMLSchema-instance", "type", (new StringBuilder()).append(namespacePrefix).append(":Server").toString(), xmlWriter);
            else
                writeAttribute("xsi", "http://www.w3.org/2001/XMLSchema-instance", "type", "Server", xmlWriter);
        }
        namespace = "https://services.mathworks.com/dws3/services/DownloadService";
        if(!namespace.equals(""))
        {
            prefix = xmlWriter.getPrefix(namespace);
            if(prefix == null)
            {
                prefix = generatePrefix(namespace);
                xmlWriter.writeStartElement(prefix, "server", namespace);
                xmlWriter.writeNamespace(prefix, namespace);
                xmlWriter.setPrefix(prefix, namespace);
            } else
            {
                xmlWriter.writeStartElement(namespace, "server");
            }
        } else
        {
            xmlWriter.writeStartElement("server");
        }
        if(localServer == null)
            writeAttribute("xsi", "http://www.w3.org/2001/XMLSchema-instance", "nil", "1", xmlWriter);
        else
            xmlWriter.writeCharacters(localServer);
        xmlWriter.writeEndElement();
        namespace = "https://services.mathworks.com/dws3/services/DownloadService";
        if(!namespace.equals(""))
        {
            prefix = xmlWriter.getPrefix(namespace);
            if(prefix == null)
            {
                prefix = generatePrefix(namespace);
                xmlWriter.writeStartElement(prefix, "transport", namespace);
                xmlWriter.writeNamespace(prefix, namespace);
                xmlWriter.setPrefix(prefix, namespace);
            } else
            {
                xmlWriter.writeStartElement(namespace, "transport");
            }
        } else
        {
            xmlWriter.writeStartElement("transport");
        }
        if(localTransport == null)
            writeAttribute("xsi", "http://www.w3.org/2001/XMLSchema-instance", "nil", "1", xmlWriter);
        else
            xmlWriter.writeCharacters(localTransport);
        xmlWriter.writeEndElement();
        namespace = "https://services.mathworks.com/dws3/services/DownloadService";
        if(!namespace.equals(""))
        {
            prefix = xmlWriter.getPrefix(namespace);
            if(prefix == null)
            {
                prefix = generatePrefix(namespace);
                xmlWriter.writeStartElement(prefix, "uniqueId", namespace);
                xmlWriter.writeNamespace(prefix, namespace);
                xmlWriter.setPrefix(prefix, namespace);
            } else
            {
                xmlWriter.writeStartElement(namespace, "uniqueId");
            }
        } else
        {
            xmlWriter.writeStartElement("uniqueId");
        }
        if(localUniqueId == null)
            writeAttribute("xsi", "http://www.w3.org/2001/XMLSchema-instance", "nil", "1", xmlWriter);
        else
            xmlWriter.writeCharacters(localUniqueId);
        xmlWriter.writeEndElement();
        xmlWriter.writeEndElement();
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
        elementList.add(new QName("https://services.mathworks.com/dws3/services/DownloadService", "server"));
        elementList.add(localServer != null ? ((Object) (ConverterUtil.convertToString(localServer))) : null);
        elementList.add(new QName("https://services.mathworks.com/dws3/services/DownloadService", "transport"));
        elementList.add(localTransport != null ? ((Object) (ConverterUtil.convertToString(localTransport))) : null);
        elementList.add(new QName("https://services.mathworks.com/dws3/services/DownloadService", "uniqueId"));
        elementList.add(localUniqueId != null ? ((Object) (ConverterUtil.convertToString(localUniqueId))) : null);
        return new ADBXMLStreamReaderImpl(qName, elementList.toArray(), attribList.toArray());
    }

    protected String localServer;
    protected String localTransport;
    protected String localUniqueId;
}
