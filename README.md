![Version](https://img.shields.io/endpoint?url=https://shield.abappm.com/github/abapPM/ABAP-Tap/src/zcl_tap.clas.abap/c_version&label=Version&color=blue)

[![License](https://img.shields.io/github/license/abapPM/ABAP-Tap?label=License&color=success)](https://github.com/abapPM/ABAP-Tap/blob/main/LICENSE)
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg?color=success)](https://github.com/abapPM/.github/blob/main/CODE_OF_CONDUCT.md)
[![REUSE Status](https://api.reuse.software/badge/github.com/abapPM/ABAP-Tap)](https://api.reuse.software/info/github.com/abapPM/ABAP-Tap)

# TAP for ABAP

This project is bringing the famous testing library [node-tap](https://node-tap.org/) to ABAP.

Stop writing long `cl_abap_unit_assert` statements. Use short `tap` methods that you can chain as well!

The project supports creating and testing of snapshots as well.

NO WARRANTIES, [MIT License](https://github.com/abapPM/ABAP-Tap/blob/main/LICENSE)

> [!IMPORTANT]
> This project is still experimental. All features described below are implemented.
> There are some test classes to validate the core features but it's missing full test coverage.
> Any help to implement more tests is much appreciated.

## Usage

Here's how you use `tap` in your test classes:

```abap
METHOD setup.
  tap = NEW zcl_tap( ).
ENDMETHOD.

METHOD test.
  DATA(i) = 42.
  tap->act( i )->equal( 42 ).
ENDMETHOD.
```

For convenience, several methods are available with shorter names compared to the TAP original. For example, you could shorten the above assertion to `t->_( i )->eq( 42 ).`

### Actual

You set the actual value using `act( )` or short `_( )`. At this time, the values of `sy-subrc`, `sy-index`, `sy-tabix`, and `sy-fdpos` will be recorded as well.

### Assertions (Expected)

The following list include the available assertion methods:

Method                   | Description
-------------------------|------------------------
`abort        `          | `cl_abap_unit_assert=>abort`
`initial`                | `cl_abap_unit_assert=>assert_initial`
`not_initial`            | `cl_abap_unit_assert=>assert_not_initial`
`bound`                  | `cl_abap_unit_assert=>assert_bound`
`not_bound`              | `cl_abap_unit_assert=>assert_not_bound`
`true` or `ok`           | `cl_abap_unit_assert=>assert_true`
`false` or `not_ok`      | `cl_abap_unit_assert=>assert_false`
`equals` or `eq`         | `cl_abap_unit_assert=>assert_equals`
`equals_float` or `eq_f` | `cl_abap_unit_assert=>assert_equals_float`
`differs` or `ne   `     | `cl_abap_unit_assert=>assert_differs` (different types passes the test!)
`cp`                     | `cl_abap_unit_assert=>assert_char_cp`
`np`                     | `cl_abap_unit_assert=>assert_char_np`
`cs`                     | `cl_abap_unit_assert=>assert_true( xsdbool( act CS exp ) )`
`ns`                     | `cl_abap_unit_assert=>assert_true( xsdbool( act NS exp ) )`
`contains`               | `cl_abap_unit_assert=>assert_table_contains`
`not_contains`           | `cl_abap_unit_assert=>assert_table_not_contains`
`error`                  | `IF act IS INSTANCE OF cx_root. cl_abap_unit_assert=>fail( ). ENDIF.`
`matches` or `re`        | `cl_abap_unit_assert=>assert_text_matches` (regex)
`return_code` or `rc`    | `cl_abap_unit_assert=>assert_return_code`
`subrc`                  | `cl_abap_unit_assert=>assert_subrc` (default 0)
`index`                  | `cl_abap_unit_assert=>assert_equals( act = sy-index )`
`tadex`                  | `cl_abap_unit_assert=>assert_equals( act = sy-tabix )`
`fdpos`                  | `cl_abap_unit_assert=>assert_equals( act = sy-fdpos )`
`throws`                 | `cl_abap_unit_assert=>fail`
`does_not_throw`         | If we get here, there was no exception. Therefore, pass the test
`type`                   | Returns the internal ABAP type of `act` (`cl_abap_typedescr=>typekind_...`)
`kind`                   | Returns the internal ABAP type category of `act` (`cl_abap_typedescr=>kind_...`)

You can chain tests as well:

```abap
READ TABLE itab INTO str.
tap->act( str )->subrc( 0 )->tabix( 2 )->eq( 'hasso' ).
```

### TAP Protocol

You can process test and record test results like [TAP Protocol](https://node-tap.org/tap-format/):

```abap
METHOD setup.
  DATA(tap) = NEW zcl_tap( logging  = abap_true ).
ENDMETHOD.

METHOD test.
  tap->plan( 1 ).

  " your tests ...

  testplan = tap->end( ).  " TAP protocol output
ENDMETHOD.
```

Additional methods: `bailout`, `passing`, `comment`, `pass`, `fail`, `skip`, `todo`.

### Snapshots

To record snapshots, set `snapshot` to `abap_true`:

```abap
DATA(tap) = NEW zcl_tap( snapshot = abap_true ).
```

In your test methods, you create snapshots as follows:

```abap
tap->snap_begin( 'SNAPSHOT_TEST' ).

DO 10 TIMES.
  tap->snap_write( |{ sy-index }| ).
ENDDO.

tap->snap_end( 'SNAPSHOT_TEST' ).
```

You can create multiple snapshots by providing a unique ID for each.

Subtests are created using `tap->test_begin( )` and `tap->test_end( )`.

By default, the snapshots are stored in the "macro" include of the class.

```
* TAP_SNAPSHOT
*
* IMPORTANT
* This snapshot file is auto-generated, but designed for humans.
* It should be checked into source control and tracked carefully.
* Re-generate by setting SNAPSHOT = ABAP_TRUE and running tests.
* Make sure to inspect the output below.  Do not ignore changes!
*

* TAP_SNAPSHOT: BEGIN OF SNAPSHOT_TEST
* 1
* 2
* 3
* 4
* 5
* 6
* 7
* 8
* 9
* 10
* TAP_SNAPSHOT: END OF SNAPSHOT_TEST
```

To match snapshots, set `snapshot` to `abap_false` (which is the default):

```abap
DATA(tap) = NEW zcl_tap( snapshot = abap_false ).
```

If a test does not match the snapshot, an exception will be raised failing the test.

Alternatively, you can use a custom include for storing the snapshots:

```abap
DATA(tap) = NEW zcl_tap(
  snapshot     = abap_true
  snap_include = 'ZSNAP_INCLUDE'
  snap_package = 'ZPROJECT'
  snap_title   = 'Snapshots for Project' ).
```

### Testing Float Numbers

You can set the default tolerance for comparison of floats (type `f`) in the constructor:

```abap
DATA(tap) = NEW zcl_tap( tolerance = '1.E-14' ).
```

## Prerequisites

SAP Basis 7.50 or higher

## Installation

Install `tap` as a global module in your system using [apm](https://abappm.com).

or

Specify the `tap` module as a dependency in your project and import it to your namespace using [apm](https://abappm.com).

## Contributions

All contributions are welcome! Read our [Contribution Guidelines](https://github.com/abapPM/ABAP-Tap/blob/main/CONTRIBUTING.md), fork this repo, and create a pull request.

You can install the developer version of ABAP TAP using [abapGit](https://github.com/abapGit/abapGit) by creating a new online repository for `https://github.com/abapPM/ABAP-Tap`.

Recommended SAP package: `$TAP`

## About

Made with ❤ in Canada

Copyright 2025 apm.to Inc. <https://apm.to>

Follow [@marcf.be](https://bsky.app/profile/marcf.be) on Blueksy and [@marcfbe](https://linkedin.com/in/marcfbe) or LinkedIn
