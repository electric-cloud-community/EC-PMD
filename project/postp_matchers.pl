@::gMatchers = (
  {
   id =>        "cs-unused",
   pattern =>          q{Avoid unused},
   action =>           q{incValueWithString("cs-unused-sum", "Unused code: 0 issues");updateSummary();},
  },
  {
   id =>        "cs-strings",
   pattern =>          q{(String|StringBuffer|strings)},
   action =>           q{incValueWithString("cs-strings-sum", "String/StringBuffer use: 0 issues");updateSummary();},
  },
  {
   id =>        "cs-basic",
   pattern =>          q{(Avoid empty |Avoid modifying |Avoid unnecessary |Avoid returning |Avoid instantiating Boolean objects|if statements|'if' statements|Overriding method |equals|Avoid using ThreadGroup|Do not hard code |Using multiple unary operators|Empty initializer)},
   action =>           q{incValueWithString("cs-basic-sum", "Basic: 0 issues");updateSummary();},
  },
  {
   id =>        "cs-braces",
   pattern =>          q{curly braces},
   action =>           q{incValueWithString("cs-braces-sum", "Braces: 0 issues");updateSummary();},
  },
  {
   id =>        "cs-design",
   pattern =>          q{(Avoid unnecessary comparisons |All methods are static|Avoid unnecessary if..then..else|Switch statements should have a default|Deeply nested if..then|Avoid reassigning parameters|Consider refactoring|Avoid instantiation through private constructors|This final field could be made static|Non-static initializers|default label|switch statement|Avoid equality comparisons|Avoid idempotent operations|When instantiating a SimpleDateFormat|Avoid protected fields in a final class|Possible unsafe assignment|Class cannot be instantiated|Consider simply returning|Document empty|exception is thrown in catch block|replaced by a local variable|Return an empty array)},
   action =>           q{incValueWithString("cs-design-sum", "Design: 0 issues");updateSummary();},
  },
  {
   id =>        "cs-coupling",
   pattern =>          q{coupling},
   action =>           q{incValueWithString("cs-coupling-sum", "Coupling: 0 issues");updateSummary();},
  },
  {
   id =>        "cs-optimization",
   pattern =>          q{(could be declared final|Avoid instantiating new objects inside loops|Use ArrayList instead of Vector|System.arraycopy is more efficient|tight loops|Unnecessary wrapper object|Do not add empty strings)},
   action =>           q{incValueWithString("cs-optimization-sum", "Optimization: 0 issues");updateSummary();},
  },
  {
   id =>        "cs-j2ee",
   pattern =>          q{(J2EE|suffixed by Bean|EJB)},
   action =>           q{incValueWithString("cs-j2ee-sum", "J2EE: 0 issues");updateSummary();},
  },
  {
   id =>        "cs-jsp",
   pattern =>          q{(JSP|attribute called 'class')},
   action =>           q{incValueWithString("cs-jsp-sum", "JSP: 0 issues");updateSummary();},
  },
  {
   id =>        "cs-jsf",
   pattern =>          q{(JSF)},
   action =>           q{incValueWithString("cs-jsf-sum", "JSF: 0 issues");updateSummary();},
  },
  {
    id =>      "cs-ruleset",
    pattern =>  q{Ruleset not found},
    action =>   q{&incValueWithString("cs-ruleset-sum", "Not found rulesets: 0");setProperty("outcome", "error" );updateSummary();
    },
  },
  {
    id =>     "cs_nfsource",
    pattern => q{File( .*) doesn't exist},
    action =>  q{&addSimpleError("cs_nfsource-sum", "File or folder $1 doesn't exist");updateSummary();
    },
  },
);

sub addSimpleError {
    my ($name, $customError) = @_;
    if(!defined $::gProperties{$name}){
        setProperty ($name, $customError);
    }
}

sub incValueWithString($;$$) {
    my ($name, $patternString, $increment) = @_;

    $increment = 1 unless defined($increment);

    my $localString = (defined $::gProperties{$name}) ? $::gProperties{$name} :
                                                        $patternString;

    $localString =~ /([^\d]*)(\d+)(.*)/;
    my $leading = $1;
    my $numeric = $2;
    my $trailing = $3;
    
    $numeric += $increment;
    $localString = $leading . $numeric . $trailing;
    diagnostic($localString, "warning", backTo("Tagging "));
    setProperty ($name, $localString);
}

sub updateSummary() {
 
    my $summary = (defined $::gProperties{"cs-unused-sum"}) ? $::gProperties{"cs-unused-sum"} . "\n" : "";
    
    $summary .= (defined $::gProperties{"cs-string-sum"}) ? $::gProperties{"cs-string-sum"} . "\n" : "";
    $summary .= (defined $::gProperties{"cs-basic-sum"}) ? $::gProperties{"cs-basic-sum"} . "\n" : "";
    $summary .= (defined $::gProperties{"cs-braces-sum"}) ? $::gProperties{"cs-braces-sum"} . "\n" : "";
    $summary .= (defined $::gProperties{"cs-design-sum"}) ? $::gProperties{"cs-design-sum"} . "\n" : "";
    $summary .= (defined $::gProperties{"cs-coupling-sum"}) ? $::gProperties{"cs-coupling-sum"} . "\n" : "";
    $summary .= (defined $::gProperties{"cs-optimization-sum"}) ? $::gProperties{"cs-optimization-sum"} . "\n" : "";
    $summary .= (defined $::gProperties{"cs-j2ee-sum"}) ? $::gProperties{"cs-j2ee-sum"} . "\n" : "";
    $summary .= (defined $::gProperties{"cs-jsp-sum"}) ? $::gProperties{"cs-jsp-sum"} . "\n" : "";
    $summary .= (defined $::gProperties{"cs-jsf-sum"}) ? $::gProperties{"cs-jsf-sum"} . "\n" : "";
    $summary .= (defined $::gProperties{"cs-ruleset-sum"}) ? $::gProperties{"cs-ruleset-sum"} . "\n" : "";
    $summary .= (defined $::gProperties{"cs_nfsource-sum"}) ? $::gProperties{"cs_nfsource-sum"} . "\n" : "";

    setProperty ("summary", $summary);
}