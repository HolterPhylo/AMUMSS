param(
[string]$xslFilePath,
[string]$xmlFilePath)

$ErrorActionPreference = "Stop";
Set-StrictMode -Version Latest;

$xmlReaderSettings = [System.Xml.XmlReaderSettings]::new();
$xmlReaderSettings.IgnoreWhitespace = $true;
$xml = [System.Xml.XmlReader]::Create([System.IO.StringReader]::new([System.IO.File]::ReadAllText($xmlFilePath)), $xmlReaderSettings);
$xslt = [System.Xml.Xsl.XslCompiledTransform]::new();
$xslt.Load($xslFilePath);

$encoding = [System.Text.UTF8Encoding]::new($false);
$writerSettings = [System.Xml.XmlWriterSettings]::new();
$writerSettings.Indent = $true;
$writerSettings.Encoding = $encoding;

try
{
$outputStream = [System.IO.MemoryStream]::new();
$outputXmlWriter = [System.Xml.XmlWriter]::Create($outputStream, $writerSettings);
$xslt.Transform($xml, $outputXmlWriter);
$outputStream.Position = 0;

[System.IO.File]::WriteAllText($xmlFilePath, $encoding.GetString($outputStream.ToArray()));
}
finally
{
$outputStream.Dispose();
}