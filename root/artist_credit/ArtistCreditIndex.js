/*
 * @flow
 * Copyright (C) 2020 MetaBrainz Foundation
 *
 * This file is part of MusicBrainz, the open internet music database,
 * and is licensed under the GPL version 2, or (at your option) any
 * later version: http://www.gnu.org/licenses/gpl-2.0.txt
 */

import * as React from 'react';

import ENTITIES from '../../entities';
import DescriptiveLink
  from '../static/scripts/common/components/DescriptiveLink';
import EntityLink
  from '../static/scripts/common/components/EntityLink';
import expand2text from '../static/scripts/common/i18n/expand2text';

import ArtistCreditLayout from './ArtistCreditLayout';

type Props = {
  +$c: CatalystContextT,
  +artistCredit: $ReadOnly<{...ArtistCreditT, +id: number}>,
  +creditedEntities: {
    +[entityType: string]: {
      +count: number,
      +entities: $ReadOnlyArray<CoreEntityT | TrackT>,
    },
  },
};

function buildSection(
  props: Props,
  entityType: string,
  title: string,
  seeAllMessage: $Call<typeof N_ln, string, string>,
) {
  const entities = props.creditedEntities[entityType];

  if (!entities.count) {
    return null;
  }

  const entityUrlFragment = ENTITIES[entityType].url;
  const url = '/artist-credit/' + props.artistCredit.id +
              '/' + entityUrlFragment;

  return (
    <React.Fragment key={entityType}>
      <h3>{title}</h3>
      <ul>
        {entities.entities.map(entity => (
          <li key={entity.id}>
            {entity.entityType === 'track' ? (
              <a href={`/track/${entity.gid}`}>
                {entity.name}
              </a>
            ) : <EntityLink entity={entity} />}
          </li>
        ))}
        {entities.count > entities.entities.length ? (
          <li key="see-all">
            <em>
              <a href={url}>
                {expand2text(
                  seeAllMessage(entities.count),
                  {num: entities.count},
                )}
              </a>
            </em>
          </li>
        ) : null}
      </ul>
    </React.Fragment>
  );
}

const ArtistCreditIndex = (
  props: Props,
): React.Element<typeof ArtistCreditLayout> => (
  <ArtistCreditLayout
    $c={props.$c}
    artistCredit={props.artistCredit}
    page=""
  >
    <p>
      {l('This artist credit is composed of the following artists:')}
    </p>
    <ul>
      {props.artistCredit.names.map((name, index) => (
        <li key={'name-' + index}>
          <DescriptiveLink entity={name.artist} />
          {name.artist.name === name.name ? null : (
            <>
              {' '}
              {exp.l(
                'credited as “{credit}”',
                {credit: name.name},
              )}
            </>
          )}
        </li>
      ))}
    </ul>
    <h2>{l('Uses')}</h2>
    {/*
      * The below use N_ln so languages with non-Germanic pluralization
      * rules (i.e., any that make number distinctions above the
      * threshold where we'll actually show the string) can translate
      * properly. However, the strings are the same in English because
      * we do not make a distinction other than for 1, which will never
      * show in this case.
      */}
    {buildSection(props, 'release_group', l('Release Groups'), N_ln(
      'See all {num} release groups',
      'See all {num} release groups',
    ))}
    {buildSection(props, 'release', l('Releases'), N_ln(
      'See all {num} releases',
      'See all {num} releases',
    ))}
    {buildSection(props, 'recording', l('Recordings'), N_ln(
      'See all {num} recordings',
      'See all {num} recordings',
    ))}
    {buildSection(props, 'track', l('Tracks'), N_ln(
      'See all {num} tracks',
      'See all {num} tracks',
    ))}
  </ArtistCreditLayout>
);

export default ArtistCreditIndex;
