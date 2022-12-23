#!/bin/bash

current_tag=$(cargo get version --pretty)

git tag "$current_tag"
git push origin "$current_tag"
