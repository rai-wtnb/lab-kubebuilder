# Hands-on

This assumes `mise cluster-up` and `mise init` are done.
The commands follow the [Kubebuilder Book Quick Start](https://book.kubebuilder.io/quick-start).

## A. Read the scaffold

`mise init` runs this inside `operator/`:

```sh
kubebuilder init --domain lab.example.com --repo github.com/rai-wtnb/lab-kubebuilder/operator
```

Start by looking at what it generated.

| Path | Contents |
|---|---|
| `PROJECT` | The project record kubebuilder maintains: the domain and the APIs you created |
| `cmd/main.go` | The entry point that builds and starts the Manager |
| `config/` | kustomize manifests: CRDs, RBAC, the Deployment, and `default` that ties them together |
| `Makefile` | Entry point for `make manifests`, `make install`, `make run` and so on |
| `Dockerfile` | The controller image |

## B. Add an API

```sh
cd operator
kubebuilder create api --group demo --version v1alpha1 --kind Greeting
```

Answer y to both "Create Resource" and "Create Controller". Two files are added.

- `api/v1alpha1/greeting_types.go`: the CRD types. Spec and Status as Go structs
- `internal/controller/greeting_controller.go`: the Reconcile implementation

## C. Write the types and install the CRD

After adding fields to Spec in `greeting_types.go`, regenerate and install.

```sh
make manifests generate   # regenerate the CRD YAML and DeepCopy
mise install-crds         # same as make install
kubectl get crd | grep lab.example.com
```

Repeat these two every time the types change.

## D. Run the controller locally

```sh
mise run-local            # same as make run; Ctrl-C to stop
```

In another terminal, apply the sample and check that Reconcile logs show up.

```sh
cd operator
kubectl apply -k config/samples/
kubectl get greetings
```

Things worth trying here:

- Add one log line to Reconcile and watch it fire on every edit of the resource
- Stop the controller, create a resource, start it again and watch it catch up (level-based)
- Update Status and confirm it with `kubectl get greeting -o yaml`

## E. Deploy into the cluster

```sh
mise deploy
mise status
mise logs
```

`mise deploy` builds the image as `lab-operator:dev`, loads it into the kind node, then runs
`make deploy`. Unlike the local run, the controller now runs with the permissions in `config/rbac/`.
A missing `// +kubebuilder:rbac:` marker shows up here for the first time, as a permission error.

Clean up with `mise undeploy`.

## F. A controller for an existing type

A controller does not need its own CRD. It can watch an existing type such as Service.

```sh
cd operator
kubebuilder create api --group core --version v1 --kind Service --controller=true --resource=false
```

`--resource=false` skips generating the type and creates only the controller.
For a type from another project (Istio's VirtualService, for example), add `--external-api-path`
and `--external-api-domain`. See
[Using External Types](https://book.kubebuilder.io/reference/using_an_external_resource).

A controller that watches Services and rewrites a VirtualService is an extension of this section.
It needs the Istio CRDs in the cluster. This lab does not install them yet.

## Tests

```sh
mise test                 # same as make test
```

envtest starts only kube-apiserver and etcd locally and runs the tests against them.
The kind cluster is not used.
