my %runPMD = (
    label       => "PMD - Code Analysis",
    procedure   => "runPMD",
    description => "Integrates PMD code analysis into Electric Commander.",
    category    => "Code Analysis"
);

$batch->deleteProperty("/server/ec_customEditors/pickerStep/EC-PMD - runPMD");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/PMD - Code Analysis");

@::createStepPickerSteps = (\%runPMD);
