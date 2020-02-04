#!/bin/sh

TEST_OUTPUT=test_output.out
EXPECTED_TEST_OUTPUT=expected_test_output.out

export TEST=yes
export TEST_RELEASE_EXISTS=no

./entrypoint.sh "contrib/testchart" "values_xyz.yml" "XXX" "YYY" "kube-test" "no" "no" "a=b,c=d" "yes" "500" "apptest" "testnamespace" "eu-west-x" &> $TEST_OUTPUT

export TEST_RELEASE_EXISTS=yes

./entrypoint.sh "contrib/testchart" "values_xyz.yml" "XXX" "YYY" "kube-test" "no" "no" "a=b,c=d" "yes" "500" "apptest" "testnamespace" "eu-west-x" &>> $TEST_OUTPUT

export TEST_RELEASE_EXISTS=yes

./entrypoint.sh "contrib/testchart" "values_xyz.yml" "XXX" "YYY" "kube-test" "no" "yes" "a=b,c=d" "yes" "500" "apptest" "testnamespace" "eu-west-x" &>> $TEST_OUTPUT

export TEST_RELEASE_EXISTS=no

./entrypoint.sh "contrib/testchart" "values_xyz.yml" "XXX" "YYY" "kube-test" "no" "yes" "a=b,c=d" "yes" "500" "apptest" "testnamespace" "eu-west-x" &>> $TEST_OUTPUT

export TEST_RELEASE_EXISTS=yes

./entrypoint.sh "contrib/testchart" "values_xyz.yml" "XXX" "YYY" "kube-test" "yes" "no" "a=b,c=d" "yes" "500" "apptest" "testnamespace" "eu-west-x" &>> $TEST_OUTPUT

./entrypoint.sh "contrib/testchart" "values_xyz.yml" "XXX" "YYY" "kube-test" "yes" "yes" "a=b,c=d" "yes" "500" "apptest" "testnamespace" "eu-west-x" &>> $TEST_OUTPUT

# Azure tests
./entrypoint.sh "contrib/testchart" "values_xyz.yml" "XXX" "YYY" "kube-test" "yes" "yes" "a=b,c=d" "yes" "500" "apptest" "testnamespace" "eu-west-x" "XXXX" "YYYY" "ZZZZ" &>> $TEST_OUTPUT
./entrypoint.sh "contrib/testchart" "values_xyz.yml" "" "" "kube-test" "yes" "no" "a=b,c=d" "yes" "500" "apptest" "testnamespace" "" "XXXX" "YYYY" "ZZZZ" &>> $TEST_OUTPUT

line_number=1
while IFS= read -r line_a
do
  line_b=`cat $EXPECTED_TEST_OUTPUT | head -n $line_number | tail -n 1`

    if [ ! "$line_a" = "$line_b" ]; then
        >&2 echo "Output and expected output doesn't fit (line number $line_number)"
        echo
        echo "Expected line: $line_b"
        echo "Actual line: $line_a"
        echo
        echo "Expected output:"
        cat $EXPECTED_TEST_OUTPUT
        echo
        echo "Test output:"
        cat $TEST_OUTPUT
        exit 1
    fi

    line_number=$(($line_number+1))
done < "$TEST_OUTPUT"

echo "All OK"
